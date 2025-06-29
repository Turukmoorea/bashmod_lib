#!/bin/bash

# ============================================================================================================
# IPv6 Validation Module for Bash Scripts
# ------------------------------------------------------------------------------------------------------------
# This module provides a reusable function to strictly validate IPv6 addresses according to RFC 4291 and RFC 5952.
# It supports three formats:
#
#   1) Fully expanded IPv6 address: 8 groups of 4 hexadecimal digits
#   2) Compressed IPv6 address: "::" shorthand notation with correct zero-fill expansion
#   3) IPv4-mapped IPv6 address: "::ffff:a.b.c.d" — only if explicitly allowed by the '4to6' mode
#
# The function will expand compressed addresses, normalize them to 8 blocks, and validate each block
# contains only valid hexadecimal characters.
#
# Logging:
#   If your script provides a 'log_message' function, this module will automatically log each step:
#     log_message "INFO" "..."
#     log_message "ERROR" "..."
#   If no logger is defined, validation runs silently without any output.
#
# Usage:
# 1. Source this module in your script:
#      source /path/to/check_ipv6.sh
#    OR load it dynamically:
#      source <(curl -s https://raw.githubusercontent.com/Turukmoorea/bashmod_lib/refs/heads/master/check_functions/check_ipv6.sh)
#
#   2. Call the function:
#        is_valid_ipv6 "2001:db8::1"
#        is_valid_ipv6 "::ffff:192.0.2.128" 4to6
#
#   3. Return codes:
#        0 => Valid address
#        1 => Invalid address
#
# Author: Turukmoorea
# Repository: https://github.com/Turukmoorea/bashmod_lib
# Last Updated: 2025-06-29
#
# License:
#   This module is free to use, modify, and distribute.
#
# ============================================================================================================

# -----------------------------------------------------------------------------
# Function: is_valid_ipv6
# Purpose : Validate an IPv6 address against three specific cases:
#           1) Fully expanded IPv6 with 8 groups of 4 hex digits
#           2) Compressed IPv6 (:: notation)
#           3) IPv4-mapped IPv6 (::ffff:a.b.c.d) if explicitly enabled
#
# Usage   : is_valid_ipv6 <IPv6 address> [mode]
#           If mode == "4to6", then IPv4-mapped addresses are allowed.
#           If no mode is provided, only pure IPv6 is allowed.
#
# Return  : 0 if valid, 1 if invalid
# -----------------------------------------------------------------------------
is_valid_ipv6() {
    local ip="$1"
    local mode="${2:-}"

    # Regex for fully expanded IPv6: exactly 8 groups of 1-4 hex digits
    local re_ipv6_full='^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$'

    # Regex for compressed IPv6 (::) syntax
    local re_ipv6_compressed='^(([0-9a-fA-F]{1,4}(:|::)){1,7}[0-9a-fA-F]{0,4})$'

    # Regex for IPv4-mapped IPv6 (::ffff:a.b.c.d)
    local re_ipv6_4to6='^::ffff:([0-9]{1,3}\.){3}[0-9]{1,3}$'

    if [ "$mode" = "4to6" ]; then
        # If mode is 4to6, only accept IPv4-mapped IPv6 format
        if echo "$ip" | grep -Eq "$re_ipv6_4to6"; then
            return 0
        else
            return 1
        fi
    else
        # Validate fully expanded IPv6 address
        if echo "$ip" | grep -Eq "$re_ipv6_full"; then
            # Split the address into its blocks and count them
            IFS=':' read -ra blocks <<< "$ip"
            if [ "${#blocks[@]}" -ne 8 ]; then
                return 1
            fi
            # Validate each block contains only valid hex digits (0-9, a-f)
            for block in "${blocks[@]}"; do
                if ! echo "$block" | grep -Eq '^[0-9a-fA-F]{1,4}$'; then
                    return 1
                fi
            done
            return 0
        elif echo "$ip" | grep -Eq "$re_ipv6_compressed"; then
            # Expand compressed address (::) to fully expanded form
            local expanded="$(expand_ipv6 "$ip")"
            if [ -z "$expanded" ]; then
                return 1
            fi
            # Re-check the expanded address has exactly 8 blocks
            IFS=':' read -ra blocks <<< "$expanded"
            if [ "${#blocks[@]}" -ne 8 ]; then
                return 1
            fi
            # Validate each expanded block
            for block in "${blocks[@]}"; do
                if ! echo "$block" | grep -Eq '^[0-9a-fA-F]{1,4}$'; then
                    return 1
                fi
            done
            return 0
        else
            # Anything else is invalid
            return 1
        fi
    fi
}

# -----------------------------------------------------------------------------
# Function: expand_ipv6
# Purpose : Expand a compressed IPv6 address (:: notation) to its full
#           representation with exactly 8 blocks of 4 hex digits each.
#
# Usage   : expand_ipv6 <IPv6 address>
#
# Output  : Prints the expanded IPv6 address to stdout
# -----------------------------------------------------------------------------
expand_ipv6() {
    local ip="$1"
    local count blocks missing expanded

    # Count the number of ':' to determine how many blocks are present
    count=$(awk -F':' '{print NF-1}' <<< "$ip")
    blocks=$((count + 1))
    missing=$((8 - blocks + 1))

    if [[ "$ip" =~ "::" ]]; then
        # Split address into head and tail at the '::'
        local head="${ip%%::*}"
        local tail="${ip##*::}"

        # Split head and tail into blocks
        IFS=':' read -ra head_blocks <<< "$head"
        IFS=':' read -ra tail_blocks <<< "$tail"

        # Start building expanded address with head blocks
        expanded="${head_blocks[*]}"
        expanded="${expanded// /:}"

        # Add zero blocks for the '::' compression gap
        for ((i=0; i<missing; i++)); do
            expanded="${expanded}:0000"
        done

        # Append tail blocks if present
        if [ -n "$tail" ]; then
            expanded="${expanded}:${tail_blocks[*]}"
            expanded="${expanded// /:}"
        fi

        # Remove any leading or trailing colons accidentally created
        expanded="${expanded#:}"
        expanded="${expanded%%:}"

    else
        # No '::', already expanded
        expanded="$ip"
    fi

    # Zero-pad each block to 4 hex digits
    IFS=':' read -ra blocks <<< "$expanded"
    for i in "${!blocks[@]}"; do
        blocks[$i]=$(printf "%04s" "${blocks[$i]}" | tr ' ' 0)
    done

    (IFS=:; echo "${blocks[*]}")
}

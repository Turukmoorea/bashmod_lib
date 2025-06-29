#!/bin/bash

# ============================================================================================================
# IPv6 Address Validation Module for Bash Scripts
# ------------------------------------------------------------------------------------------------------------
# This module provides a reusable function to validate whether a given string is a valid IPv6 address.
# It supports standard IPv6 addresses, zero compression (::), and IPv4-mapped IPv6 addresses.
#
# Usage:
# 1. Source this module in your script:
#      source /path/to/check_ipv6.sh
#    OR load it dynamically:
#      source <(curl -s https://raw.githubusercontent.com/Turukmoorea/bashmod_lib/refs/heads/master/check_functions/check_ipv6.sh)
#
# 2. Use the function in your script:
#      if is_valid_ipv6 "$address"; then
#          echo "Valid IPv6"
#      else
#          echo "Invalid IPv6"
#      fi
#
# Notes:
# - Interface identifiers (e.g. `fe80::1%eth0`) are considered invalid.
# - Addresses with more than one `::` are rejected.
# - Supports up to 7 segments if `::` is used, otherwise exactly 8 segments must be present.
# - Each segment must be a valid hexadecimal value (1 to 4 digits).
# - IPv4-mapped forms like `::ffff:192.0.2.128` are supported.
#
# Author: Turukmoorea
# Repository: https://github.com/Turukmoorea/bashmod_lib
# Last Updated: 2025-06-23
#
# License:
#   This snippet is free to use, modify, and distribute.
#
# Validation Function ========================================================================================

is_valid_ipv6() {
    local ip="$1"
    local segments=()
    local count=0
    local double_colon=0

    # Reject link-local with interface suffix
    [[ "$ip" == *%* ]] && return 1

    # Special case: IPv4-mapped IPv6 (::ffff:192.0.2.128)
    if [[ "$ip" =~ ^([0-9a-fA-F]{1,4}:){6}([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        return 0
    fi
    if [[ "$ip" =~ ::[fF]{4}:[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        return 0
    fi

    # Count "::"
    local count_dc
    count_dc=$(grep -o "::" <<< "$ip" | wc -l)
    if (( count_dc > 1 )); then
        return 1
    elif (( count_dc == 1 )); then
        double_colon=1
    fi

    # Split into segments
    IFS=':' read -ra segments <<< "$ip"

    # Remove empty segments from leading/trailing "::"
    if [[ "$ip" == ::* ]]; then
        segments=("${segments[@]:1}")
    fi
    if [[ "$ip" == *:: ]]; then
        unset 'segments[${#segments[@]}-1]'
    fi

    count=${#segments[@]}

    # Validate block count
    if (( double_colon )); then
        (( count <= 7 )) || return 1
    else
        (( count == 8 )) || return 1
    fi

    # Validate each segment
    for seg in "${segments[@]}"; do
        [[ "$seg" =~ ^[0-9a-fA-F]{1,4}$ ]] || return 1
    done

    return 0
}

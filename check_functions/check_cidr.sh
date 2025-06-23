#!/bin/bash

# ============================================================================================================
# CIDR Validation Module for Bash Scripts
# ------------------------------------------------------------------------------------------------------------
# This module provides reusable functions to validate IPv4 and IPv6 subnet masks (CIDR notation).
# It supports both full address notation (e.g. "192.168.1.0/24" or "2001:db8::/64") and standalone masks
# (e.g. "/24", "/64"). Ideal for use in configuration tools, validators or network-related scripts.
#
# Usage:
# 1. Source this module in your script:
#      source /path/to/check_cidr.sh
#    OR load it dynamically:
#      source <(curl -s https://raw.githubusercontent.com/Turukmoorea/bashmod_lib/refs/heads/master/check_functions/check_cidr.sh)
#
# 2. Use the validation functions in your script:
#      if is_valid_v4_cidr "/24"; then echo "IPv4 mask valid"; fi
#      if is_valid_v6_cidr "2001:db8::/64"; then echo "IPv6 CIDR valid"; fi
#      if is_valid_cidr "$cidr"; then echo "CIDR valid"; fi
#
# Features:
# - Supports IPv4 CIDRs with or without IP address (e.g. "10.0.0.1/8", "/16")
# - Supports IPv6 CIDRs with or without IP address (e.g. "2001:db8::/64", "/128")
# - Dispatcher function detects input type and delegates to correct validator
#
# Limitations:
# - IP addresses are not fully validated against all RFC syntax rules (focus is on CIDR range only)
# - For strict IP validation, see the separate functions:
#     https://github.com/Turukmoorea/bashmod_lib/blob/master/check_functions/check_ipv4.sh
#     https://github.com/Turukmoorea/bashmod_lib/blob/master/check_functions/check_ipv6.sh
#
# Functions:
#   is_valid_v4_cidr <string>         – Validates IPv4 CIDR format
#   is_valid_v6_cidr <string>         – Validates IPv6 CIDR format
#   is_valid_cidr <string>          – Dispatcher: detects type, extracts mask, and validates it
#
# Author: Turukmoorea
# Repository: https://github.com/Turukmoorea/bashmod_lib
# Last Updated: 2025-06-23
#
# License:
#   This snippet is free to use, modify, and distribute.
#
# CIDR Validation ============================================================================================

is_valid_v4_cidr() {
    local cidr="$1"
    local ip mask

    # Allow bare mask, e.g. "/24"
    if [[ "$cidr" =~ ^/[0-9]{1,2}$ ]]; then
        mask="${cidr:1}"
    else
        [[ "$cidr" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}$ ]] || return 1
        IFS='/' read -r ip mask <<< "$cidr"

        IFS='.' read -r o1 o2 o3 o4 <<< "$ip"
        for octet in "$o1" "$o2" "$o3" "$o4"; do
            [[ "$octet" =~ ^0$|^[1-9][0-9]*$ ]] || return 1
            ((octet >= 0 && octet <= 255)) || return 1
        done
    fi

    [[ "$mask" =~ ^[0-9]{1,2}$ ]] || return 1
    ((mask >= 0 && mask <= 32)) || return 1

    return 0
}

is_valid_v6_cidr() {
    local cidr="$1"
    local ip mask

    # Allow bare mask, e.g. "/64"
    if [[ "$cidr" =~ ^/[0-9]{1,3}$ ]]; then
        mask="${cidr:1}"
    else
        [[ "$cidr" =~ ^[^/]+/[0-9]{1,3}$ ]] || return 1
        IFS='/' read -r ip mask <<< "$cidr"

        # Simplified validation fallback (if full is_valid_ipv6 not present)
        [[ "$ip" =~ ^([0-9a-fA-F]{0,4}:){2,7}[0-9a-fA-F]{0,4}$ ]] || return 1
    fi

    [[ "$mask" =~ ^[0-9]{1,3}$ ]] || return 1
    ((mask >= 0 && mask <= 128)) || return 1

    return 0
}

is_valid_cidr() {
    local input="$1"
    local cidr=""

    # Detect and remove IP prefix if present
    if [[ "$input" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+$ ]]; then
        cidr="${input}"
        is_valid_v4_cidr "$cidr"
    elif [[ "$input" =~ ^([0-9a-fA-F]{0,4}:){2,7}[0-9a-fA-F]{0,4}/[0-9]+$ ]]; then
        cidr="${input}"
        is_valid_v6_cidr "$cidr"
    elif [[ "$input" =~ ^/[0-9]{1,2}$ ]]; then
        is_valid_v4_cidr "$input"
    elif [[ "$input" =~ ^/[0-9]{1,3}$ ]]; then
        is_valid_v6_cidr "$input"
    else
        return 1
    fi
}

#!/bin/bash

# ============================================================================================================
# IPv4 Address Validation Module for Bash Scripts
# ------------------------------------------------------------------------------------------------------------
# This module provides a reusable function to validate whether a given string is a valid IPv4 address.
# It performs strict syntax and value checks on all four octets to ensure correctness.
#
# Usage:
# 1. Source this module in your script:
#      source /path/to/check_ipv4.sh
#    OR load it dynamically:
#      source <(curl -s https://raw.githubusercontent.com/Turukmoorea/bashmod_lib/refs/heads/master/modules/check_ipv4.sh)
#
# 2. Use the function in your script:
#      if is_valid_ipv4 "$address"; then
#          echo "Valid IPv4"
#      else
#          echo "Invalid IPv4"
#      fi
#
# Notes:
# - The address must consist of exactly four numeric octets separated by dots.
# - Each octet must be in the range 0–255.
# - Leading zeros are disallowed except for the value 0 itself (e.g. 01.2.3.4 is invalid).
# - No extra whitespace or characters are allowed.
#
# Validation Function ========================================================================================

is_valid_ipv4() {
    local ip="$1"
    [[ "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] || return 1

    IFS='.' read -r o1 o2 o3 o4 <<< "$ip"
    for octet in "$o1" "$o2" "$o3" "$o4"; do
        # No leading zeroes unless it's just "0"
        [[ "$octet" =~ ^0$|^[1-9][0-9]*$ ]] || return 1
        ((octet >= 0 && octet <= 255)) || return 1
    done
    return 0
}

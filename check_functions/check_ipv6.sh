#!/bin/bash

# ============================================================================================================
# IPv6 Address Validation Module for Bash Scripts
# ------------------------------------------------------------------------------------------------------------
# This module provides a reusable function to strictly validate whether a given string is a valid IPv6 address.
# It supports standard pure IPv6 addresses and optionally allows IPv4-mapped IPv6 addresses if the special flag
# 'ipv4to6' is passed as the second argument.
#
# Features:
#   Validates standard RFC 4291 IPv6 with zero compression (::)
#   Rejects interface identifiers (zone index, e.g. %eth0)
#   Rejects CIDR suffixes (/64) and brackets ([addr])
#   Allows IPv4-mapped (::ffff:x.x.x.x) only if the flag 'ipv4to6' is set
#
# Usage:
# 1. Source this module in your script:
#      source /path/to/check_ipv6.sh
#    OR load it dynamically:
#      source <(curl -s https://raw.githubusercontent.com/YourUser/YourRepo/main/check_ipv6.sh)
#
# 2. Use the function in your script:
#      if is_valid_ipv6 "$address"; then
#          echo "Pure IPv6 address OK"
#      elif is_valid_ipv6 "$address" ipv4to6; then
#          echo "IPv6 or IPv4-mapped OK"
#      else
#          echo "Invalid address"
#      fi
#
# Notes:
# - Pure IPv6 must have exactly 8 segments or use "::" for zero compression.
# - Only one "::" is allowed.
# - Each segment must be a valid 1–4 digit hex number.
# - IPv4-mapped (::ffff:x.x.x.x) is only allowed with flag 'ipv4to6'.
# - Link-local with %zone, CIDR notation (/64) and brackets [ ] are always invalid.
#
# Author: Turukmoorea
# Repository: https://github.com/Turukmoorea/bashmod_lib
# Last Updated: 2025-06-29
#
# License:
#   This snippet is free to use, modify, and distribute.
#
# Validation Function ========================================================================================

is_valid_ipv6() {
  local ip="$1"
  local allow_ipv4_mapped="${2:-}"
  local segments=()
  local count=0
  local double_colon=0

  # Reject if empty
  [[ -z "$ip" ]] && return 1

  # Reject link-local zone identifiers (%eth0)
  [[ "$ip" == *%* ]] && return 1

  # Reject CIDR suffixes (/64 etc.)
  [[ "$ip" == */* ]] && return 1

  # Reject square brackets [addr]
  [[ "$ip" == \[* ]] || [[ "$ip" == *\] ]] && return 1

  # Allow IPv4-mapped only if flag 'ipv4to6' is set
  if [[ "$allow_ipv4_mapped" == "ipv4to6" ]]; then
    if [[ "$ip" =~ ^::[fF]{4}:([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
      # Validate the mapped IPv4 part
      local ipv4="${ip##*::ffff:}"
      if [[ "$ipv4" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        IFS='.' read -r o1 o2 o3 o4 <<< "$ipv4"
        for octet in "$o1" "$o2" "$o3" "$o4"; do
          [[ "$octet" =~ ^0$|^[1-9][0-9]*$ ]] || return 1
          ((octet >= 0 && octet <= 255)) || return 1
        done
        return 0
      else
        return 1
      fi
    fi
  fi

  # Reject IPv4-mapped if flag not set
  if [[ "$ip" =~ ^::[fF]{4}: ]]; then
    return 1
  fi

  # Count occurrences of "::"
  local count_dc
  count_dc=$(grep -o "::" <<< "$ip" | wc -l)
  if (( count_dc > 1 )); then
    return 1
  elif (( count_dc == 1 )); then
    double_colon=1
  fi

  # Split into segments
  IFS=':' read -ra segments <<< "$ip"

  # Remove leading/trailing empty if "::" is at ends
  [[ "$ip" == ::* ]] && segments=("${segments[@]:1}")
  [[ "$ip" == *:: ]] && unset 'segments[${#segments[@]}-1]'

  count=${#segments[@]}

  # Validate segment count
  if (( double_colon )); then
    (( count <= 7 )) || return 1
  else
    (( count == 8 )) || return 1
  fi

  # Validate each segment is hex 1–4 chars
  for seg in "${segments[@]}"; do
    [[ "$seg" =~ ^[0-9a-fA-F]{1,4}$ ]] || return 1
  done

  return 0
}

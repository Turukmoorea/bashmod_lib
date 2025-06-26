#!/bin/bash

# ============================================================================================================
# File Pattern Requirement Module for Bash Scripts
# ------------------------------------------------------------------------------------------------------------
# This module provides a reusable function to verify that a given file contains all required literal patterns.
# It is particularly useful for validating configuration file syntax (e.g. TSIG key files, ACL definitions).
#
# Features:
# - Takes a file path and one or more required patterns as input.
# - Checks that each pattern appears at least once in the file.
# - Uses optional `log_message` function if present (non-intrusive fallback if not defined).
# - Returns 0 if all patterns are present, 1 otherwise.
#
# Usage:
# 1. Source this module in your script:
#      source /path/to/require_file_contains_any.sh
#    OR load dynamically from a remote source (e.g. GitHub):
#      source <(curl -s https://raw.githubusercontent.com/Turukmoorea/bashmod_lib/refs/heads/master/check_functions/require_file_contains_any.sh)
#
# 2. Use the function:
#      require_file_contains_any "/etc/bind/tsig.key" "key" "tsig" "algorithm" "{" "}" ";"
#
# Notes:
# - Matching is done via grep with literal patterns (not regex).
# - `log_message` must be externally provided if logging is desired.
# - If `log_message` is not defined, output is silently suppressed.
#
# Author: Turukmoorea
# Repository: https://github.com/Turukmoorea/bashmod_lib
# Last Updated: 2025-06-26
#
# License:
#   This snippet is free to use, modify, and distribute.
#
# File Pattern Requirement Function =========================================================================

require_file_contains_any() {
    local file_path="$1"
    shift
    local missing=0

    # Internal logging wrapper.
    # Only emits log output if the log_message function is defined.
    _log() {
        local level="$1"
        local message="$2"
        if declare -F log_message >/dev/null; then
            log_message "$level" "$message"
        fi
    }

    # File must exist to proceed
    if [[ ! -f "$file_path" ]]; then
        _log "ERROR" "File not found: $file_path"
        return 1
    fi

    # Iterate over all required string patterns
    for pattern in "$@"; do
        if ! grep -qF "$pattern" "$file_path"; then
            _log "ERROR" "Required pattern '$pattern' not found in file: $file_path"
            missing=1
        else
            _log "DEBUG" "Pattern '$pattern' found in: $file_path"
        fi
    done

    # Final decision based on results
    if [[ "$missing" -eq 1 ]]; then
        _log "ERROR" "One or more required patterns missing in: $file_path"
        return 1
    fi

    _log "INFO" "All required patterns found in: $file_path"
    return 0
}

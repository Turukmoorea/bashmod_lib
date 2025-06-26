#!/bin/bash

# ============================================================================================================
# File Pattern Requirement Module for Bash Scripts
# ------------------------------------------------------------------------------------------------------------
# This module provides a reusable function to ensure that a given file contains all of a set of
# expected substrings or keywords. It is useful for sanity-checking configuration files, such as
# TSIG key files, to verify required structure elements.
#
# Features:
# - Takes a filename and one or more required patterns as arguments.
# - Verifies that each pattern occurs at least once somewhere in the file.
# - Logs findings using the externally provided `log_message` function.
# - Returns non-zero if any pattern is missing or file does not exist.
#
# Usage:
# 1. Source this module in your script:
#      source /path/to/require_file_contains_any.sh
#    OR load it dynamically from a remote source (e.g. GitHub):
#      source <(curl -s https://raw.githubusercontent.com/Turukmoorea/bashmod_lib/refs/heads/master/check_functions/check_file_contains_requirements.sh)
#
# 2. Use the function in your script:
#      require_file_contains_any "/path/to/file" "key" "tsig" "algorithm" "{" "}" ";"
#
# Notes:
# - Pattern matching is case-sensitive and based on literal string matching (not regex).
# - You must provide at least one pattern; otherwise the function will always succeed.
# - If `log_message` is not defined, output may fail silently.
#
# Author: Turukmoorea
# Repository: https://github.com/Turukmoorea/bashmod_lib
# Last Updated: 2025-06-24
#
# License:
#   This snippet is free to use, modify, and distribute.
#
# File Pattern Requirement Function =========================================================================

require_file_contains_any() {
    local file_path="$1"
    shift
    local missing=0

    if [[ ! -f "$file_path" ]]; then
        log_message "ERROR" "File not found: $file_path"
        return 1
    fi

    for pattern in "$@"; do
        if ! grep -q "$pattern" "$file_path"; then
            log_message "ERROR" "Required pattern '$pattern' not found in file: $file_path"
            missing=1
        else
            log_message "DEBUG" "Pattern '$pattern' found in: $file_path"
        fi
    done

    if [[ "$missing" -eq 1 ]]; then
        log_message "ERROR" "One or more required patterns missing in: $file_path"
        return 1
    fi

    log_message "INFO" "All required patterns found in: $file_path"
    return 0
}

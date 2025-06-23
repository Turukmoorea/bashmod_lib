#!/bin/bash

# ============================================================================================================
# Line Normalization Module for Bash Scripts
# ------------------------------------------------------------------------------------------------------------
# This module provides a reusable function to normalize a single line of text.
# It is particularly useful for parsing configuration files or similar inputs where formatting
# inconsistencies (e.g. whitespace and comments) should be ignored.
#
# Features:
# - Collapses all sequences of whitespace (spaces, tabs) into a single space.
# - Trims trailing whitespace from the end of the line.
# - Removes trailing comments introduced by a semicolon (;) or hash (#), including leading whitespace.
#
# Usage:
# 1. Source this module in your script:
#      source /path/to/normalize_line.sh
#    OR load it dynamically from a remote source (e.g. GitHub):
#      source <(curl -s https://raw.githubusercontent.com/USERNAME/REPO/branch/normalize_line.sh)
#
# 2. Use the function in your script:
#      normalized="$(normalize_line "$original")"
#
# Notes:
# - Comments beginning with `;` or `#` are completely removed, including any preceding spaces.
# - Tabs, multiple spaces, and other horizontal whitespace are reduced to a single space.
# - Only the given input string is processed – this function does not modify files.
#
# License: MIT / Public Domain (adjust as needed)
# Author: [YOUR NAME OR HANDLE]
# Repository: https://github.com/USERNAME/REPO
# Last Updated: 2025-06-23
#
# Line Normalization Function ================================================================================
normalize_line() {
    local line="$1"
    echo "$line" \
        | sed -E 's/[[:space:]]+/ /g' \
        | sed -E 's/[[:space:]]*$//' \
        | sed -E 's/[[:space:]]*;.*$//; s/[[:space:]]*#.*$//'
}

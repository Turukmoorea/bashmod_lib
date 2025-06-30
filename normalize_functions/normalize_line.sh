#!/bin/bash

# ============================================================================================================
# Line Normalization Module for Bash Scripts
# ------------------------------------------------------------------------------------------------------------
# This module provides a reusable function to normalize a single line of text.
# It is especially useful for parsing configuration files or similar inputs where formatting
# inconsistencies (e.g. whitespace or comments) should be ignored, but quoted strings must remain unchanged.
#
# Features:
# - Collapses all consecutive whitespace characters (spaces, tabs) outside of quotes into a single space.
# - Trims trailing whitespace from the end of the line.
# - Removes trailing comments that start with a semicolon (;) or hash (#), but only if they are
#   preceded by whitespace. If there is no whitespace before ; or #, it is not treated as a comment.
# - Keeps everything inside single ('') and double ("") quotes unchanged, including whitespace and comment symbols.
#
# Usage:
# 1. Source this module in your script:
#      source /path/to/normalize_line.sh
#    OR load it dynamically from a remote source (e.g. GitHub):
#      source <(curl -s https://raw.githubusercontent.com/Turukmoorea/bashmod_lib/refs/heads/master/normalize_functions/normalize_line.sh)
#
# 2. Use the function in your script:
#      normalized="$(normalize_line "$original")"
#
# Notes:
# - Quoted parts of the input remain fully intact.
# - Only whitespace and trailing comments outside of quotes are normalized or removed.
# - A comment starts with ; or # only if there is at least one whitespace character before it.
# - Tabs, multiple spaces, and other horizontal whitespace are collapsed to a single space.
# - Only the given input string is processed — this function does not modify files.
#
# Author: Turukmoorea
# Repository: https://github.com/Turukmoorea/bashmod_lib
# Last Updated: 2025-06-30
#
# License:
#   This snippet is free to use, modify, and distribute.
#
# Line Normalization Function ================================================================================

normalize_line() {
    local line="$1"
    echo "$line" | awk '
    {
        s = ""
        in_quote = 0
        quote_char = ""
        prev_char = ""
        i = 1
        while (i <= length($0)) {
            c = substr($0, i, 1)
            if (in_quote) {
                s = s c
                if (c == quote_char) {
                    in_quote = 0
                    quote_char = ""
                }
            } else {
                if (c == "\"" || c == "'\''") {
                    in_quote = 1
                    quote_char = c
                    s = s c
                } else {
                    if (c ~ /[[:space:]]/) {
                        # collapse whitespace
                        if (substr(s, length(s), 1) != " ") {
                            s = s " "
                        }
                    } else if ((c == ";" || c == "#") && prev_char ~ /[[:space:]]/) {
                        # only treat as comment if preceded by whitespace
                        break
                    } else {
                        s = s c
                    }
                }
            }
            prev_char = c
            i++
        }
        # remove trailing space
        sub(/[[:space:]]+$/, "", s)
        print s
    }'
}


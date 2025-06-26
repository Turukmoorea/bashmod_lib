# ============================================================================================================
# Natural Number Check for Bash Scripts
# ------------------------------------------------------------------------------------------------------------
# This module provides a simple helper function to check whether a given string is a natural number.
#
# Definition:
# - A natural number is a non-negative integer (0, 1, 2, 3, ...)
#
# Usage:
#   1. Source the function:
#        source /path/to/check_is_natural_number.sh
#      OR load it dynamically:
#        source <(curl -s https://raw.githubusercontent.com/Turukmoorea/bashmod_lib/refs/heads/master/check_functions/check_natural_number.sh)
#
#   2. Use in your script:
#        if is_natural_number "$value"; then ... fi
#
# Features:
# - Checks for natural numbers regardless of their size
# - Does not allow negative numbers, decimal points, or leading non-digit characters
# - Safe to use in strict mode (`set -euo pipefail`)
#
# Author: Turukmoorea
# Repository: https://github.com/Turukmoorea/bashmod_lib
# Last Updated: 2025-06-24
#
# License:
#   This snippet is free to use, modify, and distribute.
#
# Natural Number Check Function ===============================================================================
is_natural_number() {
    local value="$1"

    [[ "$value" =~ ^[0-9]+$ ]]
}

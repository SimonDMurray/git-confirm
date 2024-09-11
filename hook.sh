#!/usr/bin/env bash

set -euo pipefail

# Actual hook logic:

patterns_to_match=$(git config --get-all hooks.confirm.match)
if [ -z "$patterns_to_match" ]; then
    echo "Git-Confirm: hooks.confirm.match not set, defaulting to 'TODO'"
    echo 'Add matches with `git config --add hooks.confirm.match "string-to-match"`'
    patterns_to_match='TODO'
fi

for file in `git diff --cached -p --name-status | cut -c3-`; do
    for match_pattern in $patterns_to_match
    do
        file_changes_with_context=$(git diff -U999999999 -p --cached --color=always -- $file)
        # From the diff, get the green lines starting with '+' and including '$match_pattern'
        matched_additions=$(echo "$file_changes_with_context" | grep -C4 $'^\e\\[32m\+.*'"$match_pattern")
        if [ -n "$matched_additions" ]; then
            exit 1
        fi
    done
done
exit

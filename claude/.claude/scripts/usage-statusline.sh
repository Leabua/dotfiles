#!/bin/sh
# Claude Code statusline: saves the session JSON's rate limits for the Herdr sidebar usage bar.
in=$(cat)
dir="$HOME/.cache/claude-usage"; mkdir -p "$dir"
printf '%s' "$in" | jq -c '{rate_limits, at: now}' > "$dir/usage.json.tmp" 2>/dev/null && mv "$dir/usage.json.tmp" "$dir/usage.json"

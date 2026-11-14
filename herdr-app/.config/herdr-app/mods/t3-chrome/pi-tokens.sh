#!/usr/bin/env bash
# Prints pi's fresh tokens (input + output, not cache) over the last 5 hours, from its session logs, for the footer usage bars.
since=$(( ($(date +%s) - 5 * 3600) * 1000 ))
find "$HOME/.pi/agent/sessions" -name '*.jsonl' -mmin -300 -print0 2>/dev/null \
  | xargs -0 -r cat \
  | jq -n --argjson since "$since" '
      [inputs | (.message // .) | select(.role == "assistant" and .usage != null)
        | select(((.timestamp // 0) | if type == "string" then (sub("\\.[0-9]+Z$"; "Z") | fromdate * 1000) else . end) > $since)
        | (.usage.input // 0) + (.usage.output // 0)] | add // 0' 2>/dev/null || echo 0

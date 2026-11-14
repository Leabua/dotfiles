#!/usr/bin/env bash
# Prints Codex's rate limits (the app server's account/rateLimits/read result) as one JSON line, for the footer usage bars.
coproc C { exec codex app-server 2>/dev/null; }
printf '%s\n' \
  '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"clientInfo":{"name":"herdr-usage","version":"1"}}}' \
  '{"jsonrpc":"2.0","method":"initialized"}' \
  '{"jsonrpc":"2.0","id":2,"method":"account/rateLimits/read"}' >&"${C[1]}"
while IFS= read -r -t 20 line <&"${C[0]}"; do
  case "$line" in '{"id":2,'*) printf '%s\n' "$line"; break ;; esac
done
kill "$C_PID" 2>/dev/null

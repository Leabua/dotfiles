# Fastfetch Configuration

## Overview
System information fetcher configured with a structured, color-coded layout using box-drawing section separators.

## Configuration
- **`~/.config/fastfetch/config.jsonc`**
- Logo padding: `left = 2` (indents the ASCII art).
- Display separator: single space (compact key-value spacing).

### Modules (in order)
**Hardware** (blue) — CPU (``), GPU (`󰢮`), disk (`󰋊`), memory (``), display (`󰍹`).

**Software** (cyan) — OS (`󰣇`), WM (``), packages (`󰏖`), terminal (``), terminal font (`󰛖`).

**Uptime / Age** (magenta) — Uptime (`󰅐`) and a custom command calculating OS age from the `/` filesystem birth timestamp in days (`󰃭`).

Each section is bracketed by custom `┌─...─┐` / `└─...─┘` lines with matching color.

## Notes
- Icons are Nerd Font glyphs — requires a Nerd Font in the terminal.
- OS Age runs a one-liner `stat` + `date` command at fetch time.

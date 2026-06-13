# Yazi Configuration

## Overview
Terminal file manager (Rust) with Catppuccin Mocha flavor, async I/O, and extensive file-type-based opener/previewer rules.

## Configuration

### `yazi.toml`

#### Manager
- `ratio = [1, 2, 3]`, `sort_by = "natural"`, `sort_dir_first = true`, `show_hidden = true`.
- Mouse events: click, scroll, drag.

#### Openers
| Action | Primary | Secondary |
|--------|---------|-----------|
| `edit` | `nvim %s` (blocking) | — |
| `play` | `xdg-open` (orphan) | `mediainfo` (blocking) |
| `open` | `xdg-open` | — |
| `reveal` | `xdg-open` containing dir | `exiftool` (blocking) |
| `extract` | `ya pub extract --list` | — |
| `download` | `ya emit download --open` | `ya emit download` |

#### Open rules (MIME/URL → actions)
- Directories → edit, open, reveal.
- Text → edit, reveal.
- Images → open, reveal.
- Audio/video → play, reveal.
- JSON/JS/INI → edit, reveal.
- Archives → extract, reveal.
- Empty files → edit, reveal.
- VFS absent/stale → download.
- Everything else → open, reveal.

#### Tasks
- Workers: 3 file, 5 plugin, 5 fetch, 2 preload, 5 process.
- `image_alloc = 512MB`, `image_bound = [10000, 10000]`.
- `bizarre_retry = 3`.

#### Plugin (spotter/previewer/preloader chains)
Spotters dispatch by MIME: multi, folder, code, magick (avif/heif/jxl), svg, image, video, vfs, null, file fallback.
Preloaders: magick, svg, image, video, pdf, font.
Previewers: folder, code, json, magick, svg, image, video, pdf, archive (zip/rar/7z/tar/iso/img/etc.), font, empty, vfs, null, file fallback.

#### Input dialogs
`cursor_blink = false`. All dialogs (cd, create, filter, find, search, shell) positioned top-center with offset `[0, 2, 50, 3]`. Rename dialog appears at hovered position.

#### Confirm dialogs
Trash, delete, overwrite, quit — all centered. Quit warns about unfinished tasks.

#### Misc
- Pick: "Open with:" dialog at hovered position.
- Which: sorting disabled.

### `theme.toml`
Sets `catppuccin-mocha` for both dark and light modes.

### `package.toml`
Flavor dependency: `yazi-rs/flavors:catppuccin-mocha` (rev `0670801`).

### Flavor: `catppuccin-mocha.yazi`
Full Catppuccin Mocha theme defining:
- Manager: cwd teal, find keyword yellow/pink, markers green/red/teal/yellow.
- Tabs: active blue on base, inactive blue on surface0.
- Mode indicators: normal blue, select teal, unset flamingo.
- Status: permissions with blue/yellow/red/green, progress green/red.
- Borders, pick, input, completion, tasks, which, help, spotter, notification — all Catppuccin Mocha colors.
- Filetype colors: images teal, media yellow, archives pink, documents green, directories blue.
- Icons for special directories (`.config`, `.git`, Desktop, Documents, Downloads, etc.) and file types (link, exec, dir, etc.).

## Notes
- The Catppuccin Mocha flavor is pinned to a specific commit via `package.toml`.
- `ya pub extract` is used for archive extraction (not an external tool like `atool`).

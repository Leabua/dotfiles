# Yazi Configuration

## Overview
Yazi is a blazing fast, feature-rich terminal file manager written in Rust with async I/O. It provides a neovim-like experience for file management with plugin support, previews, and extensive customization.

## Configuration Files
- `~/.config/yazi/yazi.toml`: Main configuration file in TOML format.
- `~/.config/yazi/theme.toml`: Theme configuration file.
- `~/.config/yazi/flavors/`: Directory containing color scheme flavors.

## Setup Commands
No special setup commands are required for yazi beyond ensuring the package is installed.

## Why This Configuration
- Yazi is chosen for its incredible speed, modern interface, and powerful features that rival GUI file managers.
- The configuration is designed for efficiency and seamless integration with the development workflow:

### Manager Settings (`[mgr]`)
- `ratio = [1, 2, 3]`: Panel ratios for split views (1:2:3 for three-pane layout)
- `sort_by = "natural"`: Natural sorting (file1, file2, file10 instead of file1, file10, file2)
- `sort_dir_first = true`: Directories shown before files
- `sort_fallback = "alphabetical"`: Fallback sorting method
- `show_hidden = true`: Shows hidden files (starting with .) by default
- `mouse_events = ["click", "scroll", "drag"]`: Enables mouse support for clicking, scrolling, and dragging

### Opener Settings (`[opener]`)
Defines what happens when you open different file types:
- **Edit**: Opens files in nvim (Neovim) in blocking mode
- **Play**: 
  - Primary action: Opens with xdg-open (default opener)
  - Secondary: Shows media info with mediainfo then waits for enter
- **Open**: Uses xdg-open for general file opening
- **Reveal**: 
  - Primary: Opens containing folder with xdg-open
  - Secondary: Shows EXIF data with exiftool then waits for enter
- **Extract**: Shows extraction options with ya pub extract
- **Download**: 
  - Primary: Downloads and opens file
  - Secondary: Just downloads file

### Open Rules (`[open]`)
Associates actions with MIME types and URL patterns:
- **Directories (`*/`)**: Edit, open, reveal
- **Text files (`text/*`)**: Edit, reveal
- **Images (`image/*`)**: Open, reveal
- **Audio/Video (`{audio,video}/*`)**: Play, reveal
- **JSON/JS/Wine-Extension-Ini**: Edit, reveal
- **Archives (zip, rar, 7z, tar, etc.)**: Extract, reveal
- **Empty inodes (`inode/empty`)**: Edit, reveal
- **Virtual file system absent/stale (`vfs/{absent,stale}`)**: Download
- **Everything else (`*`)**: Open, reveal

### Tasks (`[tasks]`)
Configures worker pools for various operations:
- `file_workers = 3`: Workers for file operations
- `plugin_workers = 5`: Workers for plugin execution
- `fetch_workers = 5`: Workers for fetching data
- `preload_workers = 2`: Workers for preloading content
- `process_workers = 5`: Workers for processing tasks
- `bizarre_retry = 3`: Retry count for bizarre errors
- `image_alloc = 536870912`: 512MB allocated for image processing
- `suppress_preload = false`: Allows preloading
- `image_bound = [10000, 10000]`: Maximum image dimensions for preloading

### Plugin Configuration (`[plugin]`)
Defines how yazi identifies and handles different file types:
- **Spotters**: Identify file types for plugin selection
  - Multi-file: `multi/*` → `multi` plugin
  - Folder: `*/` → `folder` plugin
  - Code: Various text files → `code` plugin
  - Image: Various formats → `magick`, `svg`, `image` plugins
  - Video: `video/*` → `video` plugin
  - Virtual file system: `vfs/*` → `vfs` plugin
  - Error: `null/*` → `null` plugin
  - Fallback: Everything else → `file` plugin
- **Preloaders**: What to preload for different types (similar to spotters)
- **Previewers**: How to preview different types (similar to spotters)

### Input Settings (`[input]`)
Configures various input dialogs:
- `cursor_blink = false`: Disables blinking cursor in inputs
- All dialogs (cd, create, rename, filter, find, search, shell) use:
  - `origin = "top-center"` (except rename/hovered, search/top-center)
  - `offset = [0, 2, 50, 3]`: [x, y, width, height] positioning
- Shell dialogs use `origin = "top-center"`

### Confirm Settings (`[confirm]`)
Configures confirmation dialogs:
- Trash, delete, overwrite, quit confirmations all:
  - `origin = "center"`
  - Various offsets and messages
- Quit confirmation warns about unfinished tasks and suggests pressing 'w' for task manager

### Pick Settings (`[pick]`)
- `open_title = "Open with:"`: Title for open-with dialog
- `open_origin = "hovered"`: Appears near cursor
- `open_offset = [0, 1, 50, 7]`: Positioning

### Which Settings (`[which]`)
- Disables sorting for the 'which' command (`sort_by = "none"`)
- Other sorting sensitivity options set to false

## Installed Packages
Yazi package is required. See the native packages list for the exact version.

## Usage
- Launch yazi from terminal or via Hyprland keybindings
- Navigation:
  - Arrow keys / hjkl: Move cursor
  - Enter: Open selected item
  - Left arrow / h: Go up one level
  - Right arrow / l: Enter directory or open file
  - Space: Select/unselect item
  - *: Select all matching current filter
  - : (colon): Enter command mode
- Keybindings (similar to vim/neovim):
  - yy: Copy
  - pp: Paste
  - dd: Cut
  - xx: Delete
  - dd: Cut to clipboard
  - pp: Paste from clipboard
  - ss: Search
  - ff: Filter
  - gg: Go to top
  - GG: Go to bottom
  - :q: Quit
  - :w: Show tasks/workers
- Mouse (if enabled):
  - Click: Navigate/select
  - Scroll: Scroll view
  - Drag: Select multiple items
- Previews: Automatically shows previews for supported files (images, videos, text, etc.)
- Tabs: Open multiple directories in tabs (ctrl+t to open new tab, ctrl+w to close)
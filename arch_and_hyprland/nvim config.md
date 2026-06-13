# Neovim Configuration

## Overview
Lua-based Neovim config with lazy.nvim plugin manager, a custom transparent colorscheme (zednight), and a heavy focus on LSP tooling for TypeScript/Python development.

## Configuration

### Entry point: `~/.config/nvim/init.lua`
Requires four modules in order: `options`, `lazy`, `keymaps`, `autocmds`.

### `lua/config/options.lua`
- Leader: Space. Local leader: `\`.
- Indent: 2 spaces, expandtab, no wrap.
- Clipboard: `unnamedplus` (system clipboard shared by default).
- `autoread = true` — auto-reload on external change.
- Disabled perl and ruby providers.
- `fillchars.eob = " "` — hides the `~` lines below the file.
- Hybrid line numbers (absolute for current, relative for others). `scrolloff = 8`.
- Python host: auto-detects `./.venv/bin/python` if present for project-local venv support.
- 24-bit color, cursorline on, global statusline (`laststatus = 3`), swapfiles off.
- Colorscheme: `zednight` (custom, see below).

### `lua/config/keymaps.lua`
| Mapping | Action |
|---------|--------|
| `v J` | Move selected line down |
| `v K` | Move selected line up |
| `n <C-d>` / `<C-u>` | Half-page jump, cursor centered |
| `n n` / `N` | Next/prev search result, centered |
| `x <leader>p` | Paste without clobbering clipboard |
| `i <C-k>` | LSP signature help |
| `i <C-BS>` | Delete word backwards |
| `n <C-BS>` | Delete word backwards |
| `n <leader>d` | Open diagnostic float |
| `n q:` / `q?` | Disable command-line window |
| `v q:` | Disable visual command-line window |
| `n <leader>ud` | Toggle diagnostics on/off |

### `lua/config/lazy.lua`
- Bootstraps `folke/lazy.nvim` if not installed.
- Plugin specs loaded from `lua/plugins/*.lua`.
- Auto-checker disabled.

### `lua/config/autocmds.lua`
- `snacks_dashboard` filetype: disables line numbers, signcolumn, statuscolumn, foldcolumn, cursorline.
- `WinEnter` on floating windows: `<Esc>` closes the float.

### `colors/zednight.lua`
Custom colorscheme with a strict zero-orange palette:
- **Transparent editor background** (`bg = "NONE"`), solid popup background (`#1e1e1e`).
- Syntax: white text, emerald strings, teal types, magenta numbers/builtins, purple keywords, dark blue functions, light blue params/operators.
- Comments italicized — only italicized item.
- Snacks/Oil/Noice UI popups use consistent `panel_bg` and `blue_light` borders.
- Markdown code blocks forced to no background (prevents grey boxes from render-markdown).
- LSP semantic tokens locked to match syntax groups.
- Catppuccin plugin is fully commented out (returns `{}`); this is the active theme.

## Key bindings

### LSP (attached on LspAttach)
| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `K` | Hover docs (or diagnostic float if on a diagnostic) |
| `<leader>rn` | Rename |
| `<leader>ca` | Code action |
| `<leader>d` | Open diagnostic float |
| `<leader>[` / `]` | Previous / next diagnostic |
| `<leader>tt` | Toggle inline virtual text |

### File finding & navigation (Snacks picker)
| Key | Action |
|-----|--------|
| `<C-p>` | Find files (cwd) |
| `<leader><leader>` | Find files (cwd) |
| `<leader>sg` | Grep (cwd) |
| `<leader>e` | File explorer |
| `-` | Open parent directory (oil) |
| `H` / `L` | Previous / next buffer (bufferline) |
| `<leader>bd` | Close buffer |
| `<leader>bf` | Close other buffers |
| `<M-h/j/k/l>` | Tmux pane navigation (left/down/up/right) |
| `<M-\\>` | Previous tmux pane |

## Plugins

| Plugin | Purpose |
|--------|---------|
| `folke/snacks.nvim` | Dashboard, file picker, grep, explorer, indent guides, notifier, statuscolumn, words, git, bigfile handling |
| `akinsho/bufferline.nvim` | Tabline with LSP diagnostics, transparent bg, hidden separators |
| `neovim/nvim-lspconfig` | LSP client with mason for `ts_ls`, `html`, `cssls`, `lua_ls`, `tailwindcss`, `pyright` |
| `hrsh7th/nvim-cmp` | Autocompletion with LSP, buffer, path sources; LuaSnip + friendly-snippets |
| `stevearc/conform.nvim` | Format on save: prettier (JS/TS/JSON/HTML/CSS), stylua, black (Python), shfmt |
| `nvim-treesitter/nvim-treesitter` | Highlighting and indentation for lua, vim, JS/TS, python, bash, HTML, CSS, markdown |
| `folke/noice.nvim` | Replaces cmdline/messages with a popup; LSP hover/signature with rounded borders |
| `j-hui/fidget.nvim` | LSP progress spinner, suppressed during insert |
| `stevearc/oil.nvim` | File explorer as a buffer (vim-vinegar-style), remapped `h`/`l` for parent/select |
| `windwp/nvim-autopairs` | Auto-close brackets, respects treesitter context |
| `HiPhish/rainbow-delimiters.nvim` | Color-coded bracket pairs |
| `kylechui/nvim-surround` | Add/delete/change surrounding pairs |
| `MeanderingProgrammer/render-markdown.nvim` | Markdown preview with `code.style = "none"` (no grey code blocks) |
| `nvim-lualine/lualine.nvim` | Statusline: Dracula theme with transparent center section |
| `christoomey/vim-tmux-navigator` | Seamless navigation between nvim and tmux panes via Alt+hjkl |
| `catppuccin/nvim` | **Disabled** (returns `{}`) — replaced by zednight |

## Notes
- The catppuccin plugin file exists but is disabled (`return {}`). The active theme is the custom `zednight` colorscheme defined in `colors/zednight.lua`.
- `diagnostics.virtual_text = false` by default for a clean look, toggled on demand via `<leader>tt`.
- LSP uses Neovim 0.11's `vim.lsp.enable` API (not the older mason-lspconfig setup method, though mason is still used for server binaries).
- Oil's `h`/`l` keymaps override the default navigation for a tree-like feel.

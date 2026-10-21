# shellcheck shell=bash
# Match the previous zsh-syntax-highlighting style with the terminal's ANSI
# palette, so input follows Ghostty's theme through Herdr and tmux as well.

# Plain text and variables inherit the terminal's normal foreground.
ble-face -s syntax_@ none
ble-face -s varname_@ none
ble-face -s command_@ fg=2
ble-face -s filename_@ underline
ble-face -s argument_option none

# Semantic colours use palette slots rather than fixed 256-colour values.
ble-face -s command_keyword fg=3
ble-face -s command_directory fg=2,underline
ble-face -s command_suffix fg=2,underline
ble-face -s command_suffix_new fg=1,bold
ble-face -s syntax_quoted fg=3
ble-face -s syntax_quotation fg=3
ble-face -s syntax_escape fg=6
ble-face -s syntax_function_name fg=2
ble-face -s syntax_glob fg=4
ble-face -s syntax_brace fg=4
ble-face -s syntax_history_expansion fg=4
ble-face -s syntax_document_begin fg=3
ble-face -s syntax_comment fg=8
ble-face -s syntax_error fg=1,bold
ble-face -s argument_error fg=1,bold
ble-face -s filename_orphan fg=1,underline
ble-face -s filename_warning fg=1,underline

# Suggestions stay dim and use the terminal background, including insertions.
ble-face -s auto_complete fg=8,bg=none
ble-face -s region_insert fg=8,bg=none
ble-face -s disabled fg=8

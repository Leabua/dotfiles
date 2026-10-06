{ pkgs, inputs, ... }:

{ 
  environment.systemPackages = with pkgs; [

# dev tooling
      antigravity-cli
      bun
      codex
      docker
      fd
      fzf
      git
      ghostty
      glib
      jdk
      jq
      lazygit
      opencode
      neovim
      ripgrep
      pnpm
      satty
      tmux
      trash-cli
      tree-sitter
      zed-editor
      zoxide
      zsh-powerlevel10k
      zsh-autosuggestions
      zsh-syntax-highlighting
      zsh-history-substring-search

      # vector graphing 
      inkscape

# languages and runtimes
      cargo
      go
      nodejs
      rustc
      (python3.withPackages (ps: with ps; [
                             openpyxl
                             matplotlib
                             numpy
                             pandas
                             yfinance
      ]))

# c related
      gcc
      gnumake

# lsp
      basedpyright
      clang-tools
      gopls
      jdt-language-server
      lua-language-server
      rust-analyzer
      tailwindcss-language-server
      typescript-language-server
      vscode-langservers-extracted


# conform -> formatters
      black
      prettier
      rustfmt
      shfmt
      stylua
      ];
}

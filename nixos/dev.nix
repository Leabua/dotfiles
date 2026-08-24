{ pkgs, inputs, ... }:

{ 
  environment.systemPackages = with pkgs; [

# dev tooling
      bun
      docker
      fd
      fzf
      gcc
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

# languages and runtimes
      go
      nodejs
      (python3.withPackages (ps: with ps; [
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
      tailwindcss-language-server
      typescript-language-server
      vscode-langservers-extracted


# conform -> formatters
      black
      prettier
      shfmt
      stylua
      ];
}

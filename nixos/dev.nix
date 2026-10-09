{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Editors and coding agents: interactive development environments.
    (pkgs.callPackage ./codex-package.nix { })
    neovim
    opencode
    zed-editor

    # Development utilities: version control, JSON processing, and parsing tools.
    git
    jq
    lazygit
    tree-sitter

    # Languages and build tools: compilers, runtimes, and package managers.
    bun
    cargo
    gcc
    glib
    gnumake
    go
    jdk
    nodejs
    pnpm
    rustc

    # Python environment: data analysis, plotting, spreadsheets, and market data.
    (python3.withPackages (
      ps: with ps; [
        matplotlib
        numpy
        openpyxl
        pandas
        yfinance
      ]
    ))

    # Language servers: diagnostics, completion, and editor navigation.
    basedpyright
    clang-tools
    gopls
    jdt-language-server
    lua-language-server
    qt6.qtdeclarative # Provides qmlls for Quickshell/QML editing.
    rust-analyzer
    tailwindcss-language-server
    typescript-language-server
    vscode-langservers-extracted

    # Formatters: consistent source formatting across languages.
    black
    nixfmt
    prettier
    rustfmt
    shfmt
    stylua
  ];
}

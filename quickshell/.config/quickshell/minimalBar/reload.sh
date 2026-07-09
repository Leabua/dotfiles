#!/usr/bin/env bash
# /bin/bash does not exist on NixOS; use env so the right bash is found.

config="$HOME/.config/quickshell/minimalBar"
ini="$config/.qmlls.ini"

# The presence of a .qmlls.ini opts this config into quickshell's QML tooling
# support, so make sure the marker exists before launching. Quickshell replaces
# it with a symlink into its generated build dir; after a reboot that symlink
# dangles (the /run target is gone), so reset it to an empty marker.
if [ ! -e "$ini" ]; then
    rm -f "$ini"
    : > "$ini"
fi

qs -p "$config" &

# Quickshell (re)writes .qmlls.ini on launch, but its importPaths list duplicate
# Qt module roots that break the QML language server's QtQuick resolution, so
# every type shows up as "not found". Repoint importPaths at the single
# aggregated system qml dir, which the language server resolves cleanly.
# /run/current-system/sw survives nix rebuilds, unlike the raw /nix/store paths
# quickshell writes. Runs in the background, overwriting whatever quickshell
# writes during startup for a few seconds (last write wins).
(
    clean='importPaths="/run/current-system/sw/lib/qt-6/qml"'
    for _ in $(seq 1 30); do
        if [ -f "$ini" ] && grep -q '/nix/store' "$ini"; then
            sed -i --follow-symlinks "s#^importPaths=.*#$clean#" "$ini"
        fi
        sleep 0.2
    done
) &

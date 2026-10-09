# NixOS configuration

Each group starts with a single-line comment. Package lists are alphabetized within their groups.

| File | What belongs here |
| --- | --- |
| `configuration.nix` | Host settings, services, desktop integration, users, networking, and Nix maintenance |
| `hardware-configuration.nix` | Generated hardware detection, boot drivers, system partitions, swap, and microcode |
| `packages.nix` | Everyday applications, desktop utilities, shell utilities, themes, and fonts |
| `dev.nix` | Editors, coding agents, languages, build tools, language servers, and formatters |
| `codex-package.nix` | Temporary packaging fix for the pinned Codex CLI's shared daemon |
| `gaming.nix` | Optional Steam, GameMode, Gamescope, controller support, and gaming utilities |
| `flake.nix` | Dependency inputs, formatter, and host output |
| `flake.lock` | Generated dependency pins; update with Nix rather than editing by hand |

Gaming stays disabled until its import is uncommented in `configuration.nix`. Keep custom mounts such as `/mnt/hdd` there: regenerating the hardware file can overwrite manual additions.

## Maintenance

```sh
# Format every Nix file, including the optional gaming module.
nix fmt -- *.nix

# Evaluate configuration options and system assertions without activation.
nix eval --raw .#nixosConfigurations.nixos.config.system.build.toplevel.drvPath

# Build first; activate when ready.
sudo nixos-rebuild build --flake .#nixos
sudo nixos-rebuild switch --flake .#nixos
```

The files include `nixfmt` as both a flake formatter and a development package. New files must be tracked by Git before a Git-backed flake will include them.

## Review notes

- All external inputs follow the same Nixpkgs revision, and the existing lockfile pins are preserved.
- Builds use two jobs with two cores per job as a conservative starting point for this 8 GB laptop. This reduces parallel build pressure; individual builders can ignore the core hint. See the [Nix concurrency documentation](https://nix.dev/manual/nix/latest/advanced-topics/cores-vs-jobs.html).
- Automatic store optimization deduplicates files on a schedule. It preserves generations and rollback history. Garbage collection is deliberately left manual because retention is a separate policy choice. See [NixOS storage optimization](https://wiki.nixos.org/wiki/Garbage_Collection).
- Docker supplies its CLI through its NixOS module, so it does not need a second entry in the package list.
- Hyprland supplies its portal and portal configuration. GTK remains available for file dialogs; the broad `common.default = "*"` override has been removed.
- Keep `system.stateVersion = "26.05"` unchanged during routine upgrades. It controls compatibility defaults, not the Nixpkgs version. See the [state version guidance](https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion).
- Global compiler/runtime packages are convenient, but projects that need reproducible versions should use their own `devShells`. Installed packages alone do not all run in the background; disabling unused services has more impact on idle resource use.
- SSH, development firewall ports, Docker access, 32-bit graphics/audio, and the gaming module's network options preserve the existing choices. Restrict those only when their functionality is no longer needed.

## Trust boundary

The five third-party inputs remain part of the trust boundary. Lockfile revisions and download hashes ensure reproducibility and integrity, not that the upstream software is harmless. The pinned Blip module only installs its application package; it does not add a privileged service or firewall rule. This is a configuration review, not a full audit of upstream application source.

## Codex shared daemon

The pinned Nixpkgs Codex 0.161.0 package includes the Rust CLI and Code Mode host, but omits the manifest and bundled helper paths required by its daemon installer. Nixpkgs also disables `daemon_auto_start` by default. `codex-package.nix` assembles that layout from the existing Nixpkgs binaries; it copies executable files because daemon validation rejects symlinks outside the package root. Remove this workaround when Nixpkgs supplies the complete layout, and review it when updating Codex.

The system command enables `daemon_auto_start` through a wrapper. After rebuilding, the shared daemon starts on demand when you use Codex:

```sh
codex
# Or open the shared agents overview directly.
codex agents
```

This does not require a Node server, an unverified `codex-full` input, or an `enableSharedServer` setting. The official standalone installer documented by OpenAI is `https://chatgpt.com/codex/install.sh`; the Google suggestion's `https://codex.io` URL does not match the [official installation documentation](https://learn.chatgpt.com/docs/codex/cli).

# nixos-config

NixOS configurations for `inix` (Apple Silicon M-series) and `onix` (AMD/Nvidia x86_64).

## Architecture

This repo follows the [dendritic pattern](https://github.com/mightyiam/dendritic): **every `.nix` file (except `flake.nix`) is a top-level [flake-parts](https://flake.parts) module**, auto-imported via [`import-tree`](https://github.com/vic/import-tree). File paths convey the feature name, not the expression type.

### Top-level option namespaces

| Namespace | Type | Purpose |
|-----------|------|---------|
| `nixos.modules.<name>` | `deferredModule` | NixOS feature modules, merged by the module system |
| `hm.modules.<name>` | `deferredModule` | home-manager feature modules, merged and bridged into NixOS via `home-manager.nix` |
| `nixos.configurations.<host>` | submodule | Per-host assembly — declares `system` and a `module` that imports the desired `nixos.modules.*` |

### Module files

```
modules/
  nixos.nix           # Declares nixos.modules / nixos.configurations options; builds flake.nixosConfigurations
  home-manager.nix    # Declares hm.modules option; wires all hm.modules into NixOS via home-manager.sharedModules

  base.nix            # nixos.modules.base   — core system settings shared by all hosts
  desktop.nix         # nixos.modules.desktop — Wayland/niri compositor, PipeWire, fonts, portals
  himmelblau.nix      # nixos.modules.himmelblau — Entra ID / Azure AD auth
  niri-overlay.nix    # nixos.modules.niri-overlay — niri package overlay
  smb-mounts.nix      # nixos.modules.smb-mounts — SMB/CIFS network mounts
  vpn.nix             # nixos.modules.vpn — OpenConnect VPN

  hosts/
    inix.nix          # nixos.configurations.inix — Apple Silicon host assembly
    onix.nix          # nixos.configurations.onix — AMD/Nvidia host assembly

  home/
    base.nix          # hm.modules.base      — HM identity (username, homeDirectory, stateVersion)
    packages.nix      # hm.modules.packages  — user packages (home.packages)
    shell.nix         # hm.modules.shell     — shell config (fish, etc.)
    terminal.nix      # hm.modules.terminal  — terminal emulator config
    niri.nix          # hm.modules.niri      — niri window manager user config
    noctalia.nix      # hm.modules.noctalia  — Noctalia theme
```

### How it fits together

1. `flake.nix` calls `flake-parts.lib.mkFlake` and passes `import-tree ./modules` as the top-level module — every file under `modules/` is automatically imported.
2. Each file contributes to `nixos.modules.*` or `hm.modules.*` via the top-level module system's `deferredModule` merging.
3. Host files (`modules/hosts/*.nix`) declare a `nixos.configurations.<host>` whose inner `module` lists the desired `nixos.modules.*` entries in its `imports`.
4. `home-manager.nix` collects all `hm.modules.*` values and passes them as `home-manager.sharedModules` inside `nixos.modules.home-manager`, which hosts import by name.

### Adding a new feature

- **System-wide (NixOS):** create `modules/<feature>.nix` that sets `nixos.modules.<feature> = { pkgs, ... }: { ... };`, then add it to the desired host's `imports` list.
- **User/home:** create `modules/home/<feature>.nix` that sets `hm.modules.<feature> = { pkgs, ... }: { ... };` — it is automatically included for all hosts via `sharedModules`.

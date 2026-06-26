# nixos-config

Unified NixOS configurations for three machines:

| Host | Hardware | Role |
|------|----------|------|
| **inix** | Apple Silicon (M-series) | Desktop — niri Wayland compositor |
| **onix** | AMD Ryzen / Nvidia RTX 2070 | Desktop — niri Wayland compositor |
| **enix** | Intel i9-13900H mini PC | Home server — containerized services |

## Architecture

This repo follows the [dendritic pattern](https://github.com/mightyiam/dendritic): **every `.nix` file under `modules/` is a top-level [flake-parts](https://flake.parts) module**, auto-imported via [`import-tree`](https://github.com/vic/import-tree).

Host definitions are pure **composition files** — they select which named modules to include, with no inline configuration.

### Top-level option namespaces

| Namespace | Type | Purpose |
|-----------|------|---------|
| `nixos.modules.<name>` | `deferredModule` | Named NixOS feature modules |
| `hm.modules.<name>` | `deferredModule` | Named home-manager feature modules |
| `nixos.configurations.<host>` | submodule | Per-host assembly — declares `system` + `modules` list |

### Directory layout

```
flake.nix                          # Inputs + import-tree entry point
modules/
  nixos.nix                        # Schema: nixos.modules + nixos.configurations → flake.nixosConfigurations
  core/
    base.nix                       # Shared: locale, timezone, nix settings, user, SSH
    home-manager.nix               # Wires hm.modules.* into NixOS via home-manager.sharedModules
    networking-desktop.nix         # NetworkManager (desktops)
    networking-server.nix          # systemd-networkd + static IP + firewall (enix)
    server-shell.nix               # CLI tools for the server
    server-users.nix               # Server-specific user/group extensions
  desktop/
    desktop.nix                    # niri, greetd, PipeWire, fonts, portals
    easyeffects.nix                # Audio EQ preset (onix)
    himmelblau.nix                 # Entra ID / Azure AD authentication
    niri-overlay.nix               # niri test-skip overlay
    vpn.nix                        # OpenConnect GlobalProtect VPN
  hardware/
    apple-silicon.nix              # Asahi Linux, firmware, DRM (inix)
    bluetooth.nix                  # Bluetooth + btusb fix (onix)
    coral.nix                      # Google Coral TPU (enix)
    intel-gpu.nix                  # Intel QSV transcoding (enix)
    nvidia.nix                     # Nvidia proprietary driver (onix)
    onix-boot.nix                  # AMD boot + microcode (onix)
  storage/
    enix-filesystems.nix           # LVM, data disks, swap (enix)
    smb-mounts.nix                 # CIFS network mounts (desktops)
  services/                        # Containerized services (enix)
    borgbackup.nix, frigate.nix, home-assistant.nix, immich.nix,
    jellyfin.nix, media-downloads.nix, miniflux.nix, mosquitto.nix,
    navidrome.nix, omada.nix, podman.nix, prowlarr.nix, radarr.nix,
    samba.nix, sonarr.nix, ssh.nix, syncthing.nix, bazarr.nix
  secrets/
    secrets.nix                    # sops-nix wiring
  home/                            # home-manager user modules (desktops only)
    base.nix, niri.nix, noctalia.nix, packages.nix, shell.nix, terminal.nix
  hosts/
    inix.nix                       # Host composition — Apple Silicon desktop
    onix.nix                       # Host composition — AMD/Nvidia desktop
    enix.nix                       # Host composition — home server
hosts/                             # Per-host hardware-configuration.nix
  inix/, onix/, enix/
pkgs/                              # Custom package derivations
secrets/                           # Encrypted secrets (sops)
firmware/                          # Asahi peripheral firmware blobs
```

### How it fits together

1. `flake.nix` calls `flake-parts.lib.mkFlake` with `import-tree ./modules` — every `.nix` file under `modules/` is automatically imported as a flake-parts module.
2. Each file registers named modules via `nixos.modules.<name>` or `hm.modules.<name>`.
3. Host files (`modules/hosts/*.nix`) declare `nixos.configurations.<host>` with a `modules` list referencing the desired named modules.
4. `nixos.nix` builds `flake.nixosConfigurations` from those declarations, auto-injecting `networking.hostName`.
5. `home-manager.nix` collects all `hm.modules.*` and passes them as `sharedModules` — hosts that include `config.nixos.modules.home-manager` get all HM config automatically.

### Adding a new feature

- **System-wide (NixOS):** Create `modules/<domain>/<feature>.nix` that sets `nixos.modules.<feature> = { ... }: { ... };`, then add `config.nixos.modules.<feature>` to the desired host's `modules` list.
- **User/home:** Create `modules/home/<feature>.nix` that sets `hm.modules.<feature> = { ... }: { ... };` — automatically included for all desktop hosts via `sharedModules`.
- **New host:** Create `modules/hosts/<name>.nix` with a `nixos.configurations.<name>` that lists the modules it needs, plus a `hosts/<name>/hardware-configuration.nix`.

### Deploying

```bash
# Desktop (from the machine itself)
nh os switch          # or: nixos-rebuild switch --flake .#inix

# Server (remote)
nixos-rebuild switch --flake .#enix --target-host enix --use-remote-sudo
```

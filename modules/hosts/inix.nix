# Host: inix — Apple Silicon (M-series) desktop
#
# MacBook running Asahi Linux with niri Wayland compositor,
# Entra ID auth, and corporate VPN.
{ config, ... }:
{
  nixos.configurations.inix = {
    system = "aarch64-linux";
    modules = [
      # Core
      config.nixos.modules.base
      config.nixos.modules.networking-desktop
      config.nixos.modules.home-manager

      # Hardware
      config.nixos.modules.apple-silicon

      # Desktop environment
      config.nixos.modules.desktop
      config.nixos.modules.niri-overlay

      # Work tools
      config.nixos.modules.himmelblau
      config.nixos.modules.vpn

      # Storage
      config.nixos.modules.smb-mounts

      # Per-host hardware-configuration (filesystems, kernel modules)
      ../../hosts/inix/hardware-configuration.nix
    ];
  };
}

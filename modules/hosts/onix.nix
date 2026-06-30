# Host: onix — AMD/Nvidia desktop
#
# Desktop tower with Ryzen CPU, RTX 2070 Super, and Bluetooth.
# Runs niri Wayland compositor with hardware-accelerated video.
{ config, ... }:
{
  nixos.configurations.onix = {
    system = "x86_64-linux";
    modules = [
      # Core
      config.nixos.modules.base
      config.nixos.modules.networking-desktop
      config.nixos.modules.home-manager

      # Hardware
      config.nixos.modules.onix-boot
      config.nixos.modules.nvidia
      config.nixos.modules.bluetooth

      # Desktop environment
      config.nixos.modules.desktop
      config.nixos.modules.niri-overlay
      config.nixos.modules.easyeffects
      config.nixos.modules.steam

      # Work tools
      config.nixos.modules.himmelblau
      config.nixos.modules.vpn

      # Storage
      config.nixos.modules.smb-mounts

      # Per-host hardware-configuration (filesystems, kernel modules)
      ../../hosts/onix/hardware-configuration.nix
    ];
  };
}

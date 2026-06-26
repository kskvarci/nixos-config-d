# Host: enix — home server
#
# Intel i9-13900H mini PC running containerized services:
# media (Jellyfin, Sonarr, Radarr), home automation (Home Assistant, Frigate),
# file sharing (Samba, Syncthing), and network management (Omada).
{ config, ... }:
{
  nixos.configurations.enix = {
    system = "x86_64-linux";
    modules = [
      # Core
      config.nixos.modules.base
      config.nixos.modules.networking-server
      config.nixos.modules.server-users
      config.nixos.modules.server-shell

      # Hardware
      config.nixos.modules.intel-gpu
      config.nixos.modules.coral

      # Storage
      config.nixos.modules.storage-enix

      # Container runtime
      config.nixos.modules.podman

      # Services — media
      config.nixos.modules.jellyfin
      config.nixos.modules.sonarr
      config.nixos.modules.radarr
      config.nixos.modules.bazarr
      config.nixos.modules.prowlarr
      config.nixos.modules.navidrome
      config.nixos.modules.media-downloads

      # Services — home automation
      config.nixos.modules."home-assistant"
      config.nixos.modules.frigate
      config.nixos.modules.mosquitto

      # Services — infrastructure
      config.nixos.modules.samba
      config.nixos.modules.syncthing
      config.nixos.modules.miniflux
      config.nixos.modules.omada
      config.nixos.modules.borgbackup
      config.nixos.modules.ssh

      # Secrets (sops-nix — age-encrypted secrets for service credentials)
      config.nixos.modules.secrets

      # Per-host hardware-configuration (filesystems, boot, kernel)
      ../../hosts/enix/hardware-configuration.nix
    ];
  };
}

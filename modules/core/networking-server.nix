# Server networking for enix: static IP via systemd-networkd.
#
# Enix sits at 192.168.1.34 on the home LAN with systemd-resolved for DNS.
# Firewall is permissive for LAN services (Jellyfin, HA, Samba, etc.).
{ lib, ... }:
{
  nixos.modules.networking-server = { ... }: {
    # systemd-networkd for deterministic static networking
    networking.useNetworkd          = true;
    systemd.network.enable          = true;
    networking.networkmanager.enable = false;

    # Static IP on primary 10GbE NIC
    systemd.network.networks."10-lan" = {
      matchConfig.Name = "enp3s0f0np0";
      networkConfig = {
        Address = "192.168.1.34/16";
        Gateway = "192.168.1.1";
        DNS     = [ "8.8.8.8" "8.8.4.4" ];
        DHCP    = "no";
      };
    };

    # DNS resolver
    services.resolved = {
      enable   = true;
      settings.Resolve = {
        DNSSEC       = "false";
        FallbackDNS  = [ "8.8.8.8" "8.8.4.4" ];
      };
    };

    # Firewall — open ports for all self-hosted services
    networking.firewall = {
      enable = true;
      trustedInterfaces = [ "podman+" ];
      allowedTCPPorts = [
        22                         # SSH
        139 445                    # Samba
        1883 9001                  # Mosquitto MQTT + WebSocket
        2283                       # Immich
        3000                       # Z-Wave JS
        4533                       # Navidrome
        5000 5055                  # Frigate
        5030 5031 5080 50300       # slskd / qBittorrent
        6767                       # Bazarr
        6789                       # NZBGet
        6881                       # qBittorrent
        7878                       # Radarr
        8043 8088 8843             # Omada controller
        8082 8855                  # Traccar
        8091                       # Home Assistant Z-Wave
        8096 8920                  # Jellyfin
        8123                       # Home Assistant
        8191                       # FlareSolverr
        8384                       # Syncthing
        8554 8555                  # Frigate RTSP/WebRTC
        8971                       # Frigate UI
        8989                       # Sonarr
        9696                       # Prowlarr
        81                         # Miniflux
        21064 22000                # Syncthing
        29811 29812 29813 29814 29815 29816  # Omada device adoption
      ];
      allowedUDPPorts = [
        137 138                    # Samba/NetBIOS
        6881                       # qBittorrent
        7359                       # Jellyfin discovery
        8555                       # Frigate WebRTC
        21027 22000                # Syncthing
        27001 29810                # Omada app discovery
      ];
    };

    # IP forwarding for containers/VPN
    boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  };
}

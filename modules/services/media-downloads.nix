# Media download stack: Gluetun VPN, qBittorrent, NZBGet, Slskd, FlareSolverr, and Jellyseerr
{
  nixos.modules.media-downloads = {
    virtualisation.oci-containers.containers.vpn = {
      image = "qmcgaw/gluetun:latest";
      environment = {
        VPN_SERVICE_PROVIDER = "protonvpn";
        VPN_TYPE = "wireguard";
        SERVER_COUNTRIES = "Netherlands";
        TZ = "America/New_York";
        DOT = "off";
        DNS_ADDRESS = "9.9.9.9";
        IPV6 = "off";
      };
      environmentFiles = ["/run/secrets/gluetun-env"];
      ports = [
        "5030:5030"
        "5031:5031"
        "5080:5080"
        "6789:6789"
        "6881:6881"
        "6881:6881/udp"
        "8191:8191"
        "9696:9696"
        "50300:50300"
      ];
      extraOptions = [
        "--cap-add=NET_ADMIN"
        "--device=/dev/net/tun:/dev/net/tun"
        "--network=media-downloads"
        "--label=io.containers.autoupdate=registry"
      ];
    };

    virtualisation.oci-containers.containers.qbittorrent = {
      image = "lscr.io/linuxserver/qbittorrent:latest";
      environment = {
        PUID = "1000";
        PGID = "1001";
        TZ = "America/New_York";
        WEBUI_PORT = "5080";
      };
      volumes = [
        "/data/d1/appdata/qbittorrent:/config"
        "/data/d1/staging/movies/torrents:/data/staging/movies/torrents"
        "/data/d2/staging/tvshows/torrents:/data/staging/tvshows/torrents"
      ];
      dependsOn = ["vpn"];
      extraOptions = ["--network=container:vpn" "--label=io.containers.autoupdate=registry"];
    };

    virtualisation.oci-containers.containers.nzbget = {
      image = "lscr.io/linuxserver/nzbget:latest";
      environment = {
        PUID = "1000";
        PGID = "1001";
        TZ = "America/New_York";
      };
      volumes = [
        "/data/d1/appdata/nzbget:/config"
        "/data/d1/staging/movies/usenet:/data/staging/movies/usenet"
        "/data/d2/staging/tvshows/usenet:/data/staging/tvshows/usenet"
      ];
      dependsOn = ["vpn"];
      extraOptions = ["--network=container:vpn" "--label=io.containers.autoupdate=registry"];
    };

    virtualisation.oci-containers.containers.slskd = {
      image = "slskd/slskd";
      environment = {
        SLSKD_REMOTE_CONFIGURATION = "true";
        TZ = "America/New_York";
      };
      user = "1000:1001";
      volumes = [
        "/data/d1/appdata/slskd:/app"
        "/data/d1/music:/music"
        "/data/d1/musicdownloads:/downloads"
        "/data/d1/musicdownloadsinc:/incomplete"
      ];
      dependsOn = ["vpn"];
      extraOptions = ["--network=container:vpn" "--label=io.containers.autoupdate=registry"];
    };

    virtualisation.oci-containers.containers.flaresolverr = {
      image = "ghcr.io/flaresolverr/flaresolverr:latest";
      environment = {
        LOG_LEVEL = "info";
        TZ = "America/New_York";
      };
      dependsOn = ["vpn"];
      extraOptions = ["--network=container:vpn" "--label=io.containers.autoupdate=registry"];
    };

    virtualisation.oci-containers.containers.jellyseerr = {
      image = "ghcr.io/seerr-team/seerr:latest";
      ports = ["5055:5055"];
      environment = {
        TZ = "America/New_York";
      };
      user = "1000:1001";
      volumes = [
        "/data/d1/appdata/jellyseerr:/app/config"
      ];
      extraOptions = ["--network=mynetwork" "--label=io.containers.autoupdate=registry"];
    };

    systemd.services."podman-vpn" = {
      after = ["create-media-downloads-network.service"];
      wants = ["create-media-downloads-network.service"];
    };

    systemd.services."podman-jellyseerr" = {
      after = ["create-mynetwork.service"];
      wants = ["create-mynetwork.service"];
    };

    sops.secrets.gluetun-env = {
      sopsFile = ../../secrets/secrets.yaml;
    };
  };
}

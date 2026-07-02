# Prowlarr - Indexer manager on the shared app network.
#
# Prowlarr talks to Radarr/Sonarr/Bazarr and FlareSolverr by container name on
# mynetwork. Only the download clients (qBittorrent, NZBGet, slskd) sit behind
# the Gluetun killswitch; the actual IP-exposing swarm/usenet traffic stays on
# the VPN, while indexer management runs on the normal network.
{
  nixos.modules.prowlarr = {
    virtualisation.oci-containers.containers.prowlarr = {
      image = "docker.io/linuxserver/prowlarr:latest";
      ports = ["9696:9696"];
      environment = {
        PUID = "1000";
        PGID = "1001";
        TZ = "America/New_York";
      };
      volumes = [
        "/data/d1/appdata/prowlarr:/config"
      ];
      extraOptions = ["--network=mynetwork" "--label=io.containers.autoupdate=registry"];
    };

    systemd.services."podman-prowlarr" = {
      after = ["create-mynetwork.service"];
      wants = ["create-mynetwork.service"];
    };
  };
}

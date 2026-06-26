# Jellyfin media server (OCI container with Intel GPU passthrough)
{
  nixos.modules.jellyfin = {
    virtualisation.oci-containers.containers.jellyfin = {
      image = "linuxserver/jellyfin:latest";
      ports = [
        "8096:8096"
        "7359:7359/udp"
        "8920:8920"
      ];
      environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = "America/New_York";
      };
      volumes = [
        "/data/d1/appdata/jellyfin:/config"
        "/data/d1/media/movies:/data/media/movies"
        "/data/d2/media/tvshows:/data/media/tvshows"
      ];
      extraOptions = [
        "--device=/dev/dri:/dev/dri"
        "--network=mynetwork"
      ];
    };

    systemd.services."podman-jellyfin" = {
      after = ["create-mynetwork.service"];
      wants = ["create-mynetwork.service"];
    };
  };
}

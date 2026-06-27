# Radarr - Movie management in a LinuxServer OCI container
{
  nixos.modules.radarr = {
    virtualisation.oci-containers.containers.radarr = {
      image = "lscr.io/linuxserver/radarr:latest";
      ports = ["7878:7878"];
      environment = {
        PUID = "1000";
        PGID = "1001";
        TZ = "America/New_York";
      };
      volumes = [
        "/data/d1/appdata/radarr:/config"
        "/data/d1:/data"
      ];
      extraOptions = ["--network=mynetwork" "--label=io.containers.autoupdate=registry"];
    };

    systemd.services."podman-radarr" = {
      after = ["create-mynetwork.service"];
      wants = ["create-mynetwork.service"];
    };
  };
}

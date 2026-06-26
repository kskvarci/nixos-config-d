# Sonarr - TV show management in a LinuxServer OCI container
{
  nixos.modules.sonarr = {
    virtualisation.oci-containers.containers.sonarr = {
      image = "linuxserver/sonarr:latest";
      ports = ["8989:8989"];
      environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = "America/New_York";
      };
      volumes = [
        "/data/d1/appdata/sonarr:/config"
        "/data/d2:/data"
      ];
      extraOptions = ["--network=mynetwork"];
    };

    systemd.services."podman-sonarr" = {
      after = ["create-mynetwork.service"];
      wants = ["create-mynetwork.service"];
    };
  };
}

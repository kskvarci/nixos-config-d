# Bazarr - Subtitle management in a LinuxServer OCI container
{
  nixos.modules.bazarr = {
    virtualisation.oci-containers.containers.bazarr = {
      image = "lscr.io/linuxserver/bazarr:latest";
      ports = ["6767:6767"];
      environment = {
        PUID = "1000";
        PGID = "1001";
        TZ = "America/New_York";
      };
      volumes = [
        "/data/d1/appdata/bazarr:/config"
        "/data/d2:/mnt/media"
      ];
      extraOptions = ["--network=mynetwork" "--dns=9.9.9.9"];
    };

    systemd.services."podman-bazarr" = {
      after = ["create-mynetwork.service"];
      wants = ["create-mynetwork.service"];
    };
  };
}

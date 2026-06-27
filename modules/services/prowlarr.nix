# Prowlarr - Indexer manager routed through the Gluetun VPN container
{
  nixos.modules.prowlarr = {
    virtualisation.oci-containers.containers.prowlarr = {
      image = "docker.io/linuxserver/prowlarr:latest";
      environment = {
        PUID = "1000";
        PGID = "1001";
        TZ = "America/New_York";
      };
      volumes = [
        "/data/d1/appdata/prowlarr:/config"
      ];
      dependsOn = ["vpn"];
      extraOptions = ["--network=container:vpn" "--label=io.containers.autoupdate=registry"];
    };
  };
}

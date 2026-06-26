# Navidrome - Music streaming server in an OCI container
{
  nixos.modules.navidrome = {
    virtualisation.oci-containers.containers.navidrome = {
      image = "deluan/navidrome:latest";
      ports = ["4533:4533"];
      environment = {
        TZ = "America/New_York";
        ND_ADDRESS = "0.0.0.0";
        ND_PORT = "4533";
        ND_MUSICFOLDER = "/music";
        ND_DATAFOLDER = "/data";
      };
      volumes = [
        "/data/d1/appdata/navidrome:/data"
        "/data/d1/music:/music:ro"
      ];
    };
  };
}

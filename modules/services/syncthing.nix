# Syncthing - File synchronization in a LinuxServer OCI container
{
  nixos.modules.syncthing = {
    virtualisation.oci-containers.containers.syncthing = {
      image = "lscr.io/linuxserver/syncthing:latest";
      ports = [
        "8384:8384"
        "22000:22000"
        "22000:22000/udp"
        "21027:21027/udp"
      ];
      environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = "America/New_York";
      };
      volumes = [
        "/data/d1/appdata/syncthing:/config"
        "/data/d1/syncthing:/data1"
      ];
    };
  };
}

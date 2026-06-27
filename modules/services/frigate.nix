# Frigate NVR as an OCI container with Coral and Intel GPU passthrough
{
  nixos.modules.frigate = {
    virtualisation.oci-containers.containers.frigate = {
      image = "ghcr.io/blakeblackshear/frigate:stable";
      ports = [
        "5000:5000"
        "8554:8554"
        "8555:8555/tcp"
        "8555:8555/udp"
        "8971:8971"
      ];
      environment = {
        TZ = "America/New_York";
      };
      environmentFiles = ["/run/secrets/frigate-env"];
      volumes = [
        "/data/d1/appdata/frigate:/config"
        "/data/d2/frigate:/media/frigate"
      ];
      extraOptions = [
        "--privileged"
        "--shm-size=200m"
        "--device=/dev/dri:/dev/dri"
        "--device=/dev/apex_0:/dev/apex_0"
        "--mount=type=tmpfs,target=/tmp/cache,tmpfs-size=1000000000"
        "--label=io.containers.autoupdate=registry"
      ];
    };

    sops.secrets.frigate-env = {
      sopsFile = ../../secrets/secrets.yaml;
    };
  };
}

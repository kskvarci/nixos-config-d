# Miniflux - RSS reader with PostgreSQL, both as OCI containers
{
  nixos.modules.miniflux = {
    virtualisation.oci-containers.containers.miniflux-db = {
      image = "docker.io/library/postgres:15";
      environment = {
        POSTGRES_DB = "miniflux";
        POSTGRES_USER = "miniflux";
      };
      environmentFiles = ["/run/secrets/miniflux-db-env"];
      volumes = [
        "/data/d1/appdata/miniflux-db:/var/lib/postgresql/data"
      ];
      extraOptions = ["--network=miniflux" "--label=io.containers.autoupdate=registry"];
    };

    virtualisation.oci-containers.containers.miniflux = {
      image = "docker.io/miniflux/miniflux:latest";
      ports = ["81:8080"];
      environment = {
        TZ = "America/New_York";
        LISTEN_ADDR = "0.0.0.0:8080";
        BASE_URL = "http://cumulus:81";
        RUN_MIGRATIONS = "1";
        CREATE_ADMIN = "1";
      };
      environmentFiles = ["/run/secrets/miniflux-env"];
      dependsOn = ["miniflux-db"];
      extraOptions = ["--network=miniflux" "--label=io.containers.autoupdate=registry"];
    };

    systemd.services."podman-miniflux-db" = {
      after = ["create-miniflux-network.service"];
      wants = ["create-miniflux-network.service"];
    };

    systemd.services."podman-miniflux" = {
      after = ["create-miniflux-network.service"];
      wants = ["create-miniflux-network.service"];
    };

    sops.secrets.miniflux-db-env = {
      sopsFile = ../../secrets/secrets.yaml;
    };
    sops.secrets.miniflux-env = {
      sopsFile = ../../secrets/secrets.yaml;
    };
  };
}

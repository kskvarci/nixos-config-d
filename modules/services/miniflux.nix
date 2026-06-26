# Miniflux - RSS reader with PostgreSQL, both as OCI containers
{
  nixos.modules.miniflux = {
    virtualisation.oci-containers.containers.miniflux-db = {
      image = "postgres:15";
      environment = {
        POSTGRES_DB = "miniflux";
        POSTGRES_USER = "miniflux";
        POSTGRES_PASSWORD = "CHANGE_ME"; # TODO: source from sops-nix.
      };
      volumes = [
        "/data/d1/appdata/miniflux-db:/var/lib/postgresql/data"
      ];
      extraOptions = ["--network=miniflux"];
    };

    virtualisation.oci-containers.containers.miniflux = {
      image = "miniflux/miniflux:latest";
      ports = ["81:8080"];
      environment = {
        TZ = "America/New_York";
        LISTEN_ADDR = "0.0.0.0:8080";
        BASE_URL = "http://cumulus:81";
        RUN_MIGRATIONS = "1";
        CREATE_ADMIN = "1";
        ADMIN_USERNAME = "CHANGE_ME"; # TODO: source from sops-nix.
        ADMIN_PASSWORD = "CHANGE_ME"; # TODO: source from sops-nix.
        DATABASE_URL = "postgres://miniflux:CHANGE_ME@miniflux-db:5432/miniflux?sslmode=disable"; # TODO: source from sops-nix.
      };
      dependsOn = ["miniflux-db"];
      extraOptions = ["--network=miniflux"];
    };

    systemd.services."podman-miniflux-db" = {
      after = ["create-miniflux-network.service"];
      wants = ["create-miniflux-network.service"];
    };

    systemd.services."podman-miniflux" = {
      after = ["create-miniflux-network.service"];
      wants = ["create-miniflux-network.service"];
    };
  };
}

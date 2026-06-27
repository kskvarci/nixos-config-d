# Immich - server, machine learning, Redis, and PostgreSQL as OCI containers
{
  nixos.modules.immich = {
    virtualisation.oci-containers.containers.immich_server = {
      image = "ghcr.io/immich-app/immich-server:release";
      ports = ["2283:2283"];
      environment = {
        DB_HOSTNAME = "immich_postgres";
        DB_USERNAME = "postgres";
        DB_DATABASE_NAME = "Pointy3345";
        REDIS_HOSTNAME = "immich_redis";
        IMMICH_MACHINE_LEARNING_URL = "http://immich_machine_learning:3003";
        TZ = "America/New_York";
      };
      environmentFiles = ["/run/secrets/immich-env"];
      volumes = [
        "/data/d2/immich_upload:/usr/src/app/upload"
        "/data/d2/photos:/data/d2/photos:ro"
        "/etc/localtime:/etc/localtime:ro"
      ];
      dependsOn = [
        "immich_redis"
        "immich_postgres"
        "immich_machine_learning"
      ];
      extraOptions = ["--network=immich" "--label=io.containers.autoupdate=registry"];
    };

    virtualisation.oci-containers.containers.immich_machine_learning = {
      image = "ghcr.io/immich-app/immich-machine-learning:release";
      volumes = ["/data/d1/appdata/immich-model-cache:/cache"];
      environment = {
        TZ = "America/New_York";
      };
      extraOptions = ["--network=immich" "--label=io.containers.autoupdate=registry"];
    };

    virtualisation.oci-containers.containers.immich_redis = {
      image = "docker.io/valkey/valkey:8-bookworm";
      extraOptions = ["--network=immich" "--label=io.containers.autoupdate=registry"];
    };

    virtualisation.oci-containers.containers.immich_postgres = {
      image = "docker.io/tensorchord/pgvecto-rs:pg14-v0.2.0";
      environment = {
        POSTGRES_USER = "postgres";
        POSTGRES_DB = "Pointy3345";
        POSTGRES_INITDB_ARGS = "--data-checksums";
      };
      environmentFiles = ["/run/secrets/immich-db-env"];
      volumes = [
        "/data/d1/appdata/immich/postgres:/var/lib/postgresql/data"
      ];
      cmd = [
        "postgres"
        "-c"
        "shared_preload_libraries=vectors.so"
        "-c"
        "search_path=\\\"$$user\\\", public, vectors"
        "-c"
        "logging_collector=on"
        "-c"
        "max_wal_size=2GB"
        "-c"
        "shared_buffers=512MB"
        "-c"
        "wal_compression=on"
      ];
      extraOptions = ["--network=immich" "--label=io.containers.autoupdate=registry"];
    };

    systemd.services."podman-immich_server" = {
      after = ["create-immich-network.service"];
      wants = ["create-immich-network.service"];
    };

    systemd.services."podman-immich_machine_learning" = {
      after = ["create-immich-network.service"];
      wants = ["create-immich-network.service"];
    };

    systemd.services."podman-immich_redis" = {
      after = ["create-immich-network.service"];
      wants = ["create-immich-network.service"];
    };

    systemd.services."podman-immich_postgres" = {
      after = ["create-immich-network.service"];
      wants = ["create-immich-network.service"];
    };

    sops.secrets.immich-env = {
      sopsFile = ../../secrets/secrets.yaml;
    };
    sops.secrets.immich-db-env = {
      sopsFile = ../../secrets/secrets.yaml;
    };
  };
}

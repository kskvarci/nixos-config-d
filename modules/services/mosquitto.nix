# Mosquitto MQTT broker in an OCI container
{
  nixos.modules.mosquitto = {
    environment.etc."mosquitto/mosquitto.conf".text = ''
      persistence true
      persistence_location /mosquitto/data/
      log_dest stdout

      listener 1883 0.0.0.0
      allow_anonymous true

      listener 9001 0.0.0.0
      protocol websockets
      allow_anonymous true
    '';

    systemd.tmpfiles.rules = [
      "d /data/d1/appdata/mosquitto 0755 root root -"
      "d /data/d1/appdata/mosquitto/data 0755 root root -"
      "d /data/d1/appdata/mosquitto/log 0755 root root -"
    ];

    virtualisation.oci-containers.containers.mqtt5 = {
      image = "docker.io/library/eclipse-mosquitto:latest";
      ports = [
        "1883:1883"
        "9001:9001"
      ];
      volumes = [
        "/etc/mosquitto/mosquitto.conf:/mosquitto/config/mosquitto.conf:ro"
        "/data/d1/appdata/mosquitto/data:/mosquitto/data"
        "/data/d1/appdata/mosquitto/log:/mosquitto/log"
      ];
      extraOptions = ["--label=io.containers.autoupdate=registry"];
    };
  };
}

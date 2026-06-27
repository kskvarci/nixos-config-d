# Home Assistant and Z-Wave JS UI as OCI containers
{
  nixos.modules.home-assistant = {
    virtualisation.oci-containers.containers.homeassistant = {
      image = "ghcr.io/home-assistant/home-assistant:stable";
      environment = {
        TZ = "America/New_York";
      };
      volumes = [
        "/data/d1/appdata/homeassistant:/config"
        "/etc/localtime:/etc/localtime:ro"
      ];
      extraOptions = [
        "--network=host"
        "--device=/dev/zigbee:/dev/zigbee"
        "--mount=type=bind,src=/run/dbus,dst=/run/dbus,ro"
      ];
    };

    virtualisation.oci-containers.containers.zwave-js-ui = {
      image = "zwavejs/zwave-js-ui:latest";
      environment = {
        TZ = "America/New_York";
      };
      volumes = [
        "/data/d1/appdata/zwave-js-ui:/usr/src/app/store"
      ];
      extraOptions = [
        "--network=host"
        "--device=/dev/zwave:/dev/zwave"
      ];
    };
  };
}

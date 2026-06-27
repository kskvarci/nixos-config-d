# Omada Controller - TP-Link network management in an OCI container
{
  nixos.modules.omada = {
    virtualisation.oci-containers.containers.omada-controller = {
      image = "docker.io/mbentley/omada-controller:5.15";
      environment = {
        MANAGE_HTTP_PORT = "8088";
        MANAGE_HTTPS_PORT = "8043";
        PORTAL_HTTP_PORT = "8088";
        PORTAL_HTTPS_PORT = "8843";
        PORT_APP_DISCOVERY = "27001";
        PORT_ADOPT_V1 = "29812";
        PORT_UPGRADE_V1 = "29813";
        PORT_MANAGER_V1 = "29811";
        PORT_MANAGER_V2 = "29814";
        PORT_DISCOVERY = "29810";
        PORT_TRANSFER_V2 = "29815";
        PORT_RTTY = "29816";
        SHOW_SERVER_LOGS = "true";
        SHOW_MONGODB_LOGS = "false";
        TZ = "America/New_York";
      };
      volumes = [
        "/data/d1/appdata/omada/data:/opt/tplink/EAPController/data"
        "/data/d1/appdata/omada/logs:/opt/tplink/EAPController/logs"
      ];
      extraOptions = [
        "--network=host"
        "--ulimit=nofile=4096:8192"
        "--stop-timeout=60"
        "--label=io.containers.autoupdate=registry"
        "--health-cmd=none"
      ];
    };
  };
}

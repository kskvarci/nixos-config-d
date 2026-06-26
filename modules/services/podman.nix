# Podman/OCI runtime and shared container networks
{
  nixos.modules.podman = {pkgs, ...}: let
    mkPodmanNetwork = name: {
      description = "Create Podman network ${name}";
      wantedBy = ["multi-user.target"];
      after = ["network-online.target"];
      wants = ["network-online.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.runtimeShell} -lc '${pkgs.podman}/bin/podman network exists ${name} || ${pkgs.podman}/bin/podman network create ${name}'";
      };
    };
  in {
    virtualisation.podman = {
      enable = true;
      dockerCompat = false;
      defaultNetwork.settings.dns_enabled = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
        flags = ["--all"];
      };
    };

    virtualisation.oci-containers.backend = "podman";

    systemd.services.create-mynetwork = mkPodmanNetwork "mynetwork";
    systemd.services.create-media-downloads-network = mkPodmanNetwork "media-downloads";
    systemd.services.create-miniflux-network = mkPodmanNetwork "miniflux";
    systemd.services.create-immich-network = mkPodmanNetwork "immich";
  };
}

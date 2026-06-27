# Google Coral PCIe TPU support for Frigate object detection.
#
# Requires the gasket kernel module and apex udev rules to expose /dev/apex_0.
{ ... }:
{
  nixos.modules.coral = { pkgs, config, ... }: {
    # Gasket driver for PCIe Coral
    boot.extraModulePackages = [ config.boot.kernelPackages.gasket ];
    boot.kernelModules = [ "gasket" "apex" ];

    # udev rules to set permissions on /dev/apex_0
    services.udev.extraRules = ''
      SUBSYSTEM=="apex", MODE="0660", GROUP="video"
    '';

    environment.systemPackages = [ pkgs.libedgetpu ];
  };
}

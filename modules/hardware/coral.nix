# Google Coral TPU (USB) support for Frigate object detection.
{ ... }:
{
  nixos.modules.coral = { pkgs, ... }: {
    # Coral USB accelerator udev rules
    services.udev.packages = [ pkgs.libedgetpu ];

    environment.systemPackages = [ pkgs.libedgetpu ];
  };
}

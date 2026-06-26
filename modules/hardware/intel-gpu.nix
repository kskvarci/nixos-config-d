# Intel integrated GPU with Quick Sync Video (QSV) for hardware transcoding.
#
# Used by enix (home server) for Jellyfin/Frigate video processing.
{ ... }:
{
  nixos.modules.intel-gpu = { pkgs, ... }: {
    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-compute-runtime
      ];
    };

    # Allow containers to access the GPU via /dev/dri
    hardware.graphics.enable32Bit = true;
  };
}

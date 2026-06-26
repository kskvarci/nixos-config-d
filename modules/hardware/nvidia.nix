# Nvidia proprietary GPU driver for onix (RTX 2070 Super on Turing architecture).
#
# Enables modesetting for Wayland/niri, power management, and VA-API
# hardware video decode via nvidia-vaapi-driver.
{ ... }:
{
  nixos.modules.nvidia = { pkgs, ... }: {
    # Use the proprietary Nvidia driver
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      modesetting.enable     = true;
      open                   = false;
      nvidiaSettings         = true;
      powerManagement.enable = true;
    };

    # Hardware-accelerated video decode/encode
    hardware.graphics = {
      enable        = true;
      extraPackages = [ pkgs.nvidia-vaapi-driver ];
    };

    # Wayland + GBM environment for niri compositor
    environment.sessionVariables = {
      GBM_BACKEND              = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      NVD_BACKEND              = "direct";
    };
  };
}

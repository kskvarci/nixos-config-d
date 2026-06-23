# AMD desktop with Nvidia RTX 2070 Super.
{ config, inputs, ... }:
{
  nixos.configurations.onix = {
    system = "x86_64-linux";
    module = { pkgs, ... }: {
      imports = with config.nixos.modules; [
        base
        desktop
        niri-overlay
        himmelblau
        smb-mounts
        home-manager
        ../../hosts/onix/hardware-configuration.nix
      ];

      networking.hostName           = "onix";
      networking.networkmanager.enable = true;

      boot.loader.systemd-boot.enable      = true;
      boot.loader.efi.canTouchEfiVariables = true;

      hardware.cpu.amd.updateMicrocode = true;

      hardware.bluetooth.enable      = true;
      hardware.bluetooth.powerOnBoot = true;
      services.blueman.enable        = true;

      # Nvidia proprietary driver — required for Wayland/niri on Turing GPUs.
      services.xserver.videoDrivers = [ "nvidia" ];
      hardware.nvidia = {
        modesetting.enable       = true;
        open                     = false;
        nvidiaSettings           = true;
        powerManagement.enable   = false;
      };

      hardware.graphics = {
        enable        = true;
        extraPackages = [ pkgs.nvidia-vaapi-driver ];
      };

      environment.sessionVariables = {
        GBM_BACKEND               = "nvidia-drm";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        NVD_BACKEND               = "direct";
      };

      # Override niri to skip tests (overlay patches pkgs.niri; this ensures
      # the niri module itself also uses the patched package).
      programs.niri.package = pkgs.niri.overrideAttrs (_: { doCheck = false; });

      system.stateVersion = "25.11";
    };
  };
}

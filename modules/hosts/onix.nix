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
        vpn
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

      # Disable autosuspend on the btusb adapter — prevents BT mouse disconnects.
      boot.extraModprobeConfig = ''
        options btusb enable_autosuspend=0
      '';

      # Nvidia proprietary driver — required for Wayland/niri on Turing GPUs.
      services.xserver.videoDrivers = [ "nvidia" ];
      hardware.nvidia = {
        modesetting.enable       = true;
        open                     = false;
        nvidiaSettings           = true;
        powerManagement.enable   = true;
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

      # Deploy EasyEffects config for Hifiman Sundara / JDS Atom DAC.
      # Copied (not symlinked) so EasyEffects can write runtime state between rebuilds.
      home-manager.users.kskvarci.home.activation.easyeffectsConfig =
        inputs.home-manager.lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          mkdir -p "$HOME/.config/easyeffects/db"
          for f in easyeffectsrc equalizerrc; do
            install -m644 ${../../hosts/onix/easyeffects}/$f \
              "$HOME/.config/easyeffects/db/$f"
          done
        '';

      system.stateVersion = "25.11";
    };
  };
}

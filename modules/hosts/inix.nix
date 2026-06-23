# Bare-metal Apple Silicon (M-series) host.
{ config, inputs, ... }:
{
  nixos.configurations.inix = {
    system = "aarch64-linux";
    module = { ... }: {
      imports = with config.nixos.modules; [
        base
        desktop
        niri-overlay
        himmelblau
        smb-mounts
        vpn
        home-manager
        ../../hosts/inix/hardware-configuration.nix
        inputs.apple-silicon.nixosModules.default
      ];

      hardware.asahi.peripheralFirmwareDirectory = ../../firmware;

      boot.loader.systemd-boot.enable      = true;
      boot.loader.efi.canTouchEfiVariables = false;
      boot.kernelParams                    = [ "appledrm.show_notch=1" ];

      # apple-drm (card1) is display-only; card2 is the asahi render GPU.
      environment.sessionVariables.NIRI_DRM_DEVICE = "/dev/dri/card2";

      networking.hostName                      = "inix";
      networking.networkmanager.enable         = true;
      networking.networkmanager.wifi.backend   = "iwd";

      # Apple Silicon binary cache — avoids rebuilding the custom kernel from source.
      nix.settings.extra-substituters      = [ "https://nixos-apple-silicon.cachix.org" ];
      nix.settings.extra-trusted-public-keys = [
        "nixos-apple-silicon.cachix.org-1:8psDu5SA5dAD7qA0zMy5UT292TxeEPzIz8VVEr2Js20="
      ];

      system.stateVersion = "25.11";
    };
  };
}

# Apple Silicon (Asahi) hardware support for inix.
#
# Provides: kernel, firmware, DRM device assignment, boot loader,
# binary cache for pre-built asahi kernels, and wifi backend.
{ inputs, ... }:
{
  nixos.modules.apple-silicon = { ... }: {
    imports = [ inputs.apple-silicon.nixosModules.default ];

    # Peripheral firmware blobs (Wi-Fi, Bluetooth, etc.)
    hardware.asahi.peripheralFirmwareDirectory = ../../firmware;

    # Systemd-boot (UEFI)
    boot.loader.systemd-boot.enable      = true;
    boot.loader.efi.canTouchEfiVariables = false;

    # Show the notch area as usable screen space
    boot.kernelParams = [ "appledrm.show_notch=1" ];

    # apple-drm (card1) is display-only; card2 is the asahi render GPU.
    environment.sessionVariables.NIRI_DRM_DEVICE = "/dev/dri/card2";

    # iwd is more reliable than wpa_supplicant on Apple hardware.
    networking.networkmanager.wifi.backend = "iwd";

    # Apple Silicon binary cache — avoids rebuilding the custom kernel from source.
    nix.settings.extra-substituters       = [ "https://nixos-apple-silicon.cachix.org" ];
    nix.settings.extra-trusted-public-keys = [
      "nixos-apple-silicon.cachix.org-1:8psDu5SA5dAD7qA0zMy5UT292TxeEPzIz8VVEr2Js20="
    ];

    system.stateVersion = "25.11";
  };
}

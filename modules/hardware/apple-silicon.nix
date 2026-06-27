# Apple Silicon (Asahi) hardware support for inix.
#
# Provides: kernel, firmware, DRM device assignment, boot loader,
# binary cache for pre-built asahi kernels, and wifi backend.
{ inputs, ... }:
{
  nixos.modules.apple-silicon = { pkgs, ... }: {
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

    # brcmfmac power saving causes frequent Wi-Fi drops on Apple hardware.
    networking.networkmanager.wifi.powersave = false;

    # NetworkManager's powersave flag isn't reliably honored with the iwd
    # backend, so force 802.11 power save off on the interface directly.
    # Bound to the wlan0 device unit so it re-applies on every (re)appearance
    # of the interface (driver reload, resume, reconnect).
    systemd.services.wifi-powersave-off = {
      description = "Disable Wi-Fi power saving (brcmfmac)";
      bindsTo     = [ "sys-subsystem-net-devices-wlan0.device" ];
      after       = [ "sys-subsystem-net-devices-wlan0.device" ];
      wantedBy    = [ "sys-subsystem-net-devices-wlan0.device" ];
      serviceConfig = {
        Type      = "oneshot";
        ExecStart = "${pkgs.iw}/bin/iw dev wlan0 set power_save off";
      };
    };

    # Apple Silicon binary cache — avoids rebuilding the custom kernel from source.
    nix.settings.extra-substituters       = [ "https://nixos-apple-silicon.cachix.org" ];
    nix.settings.extra-trusted-public-keys = [
      "nixos-apple-silicon.cachix.org-1:8psDu5SA5dAD7qA0zMy5UT292TxeEPzIz8VVEr2Js20="
    ];

    system.stateVersion = "25.11";
  };
}

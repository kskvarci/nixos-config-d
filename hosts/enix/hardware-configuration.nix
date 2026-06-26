# Hardware configuration for enix (home server).
#
# Micro Computer Venus Series, Intel i9-13900H, 32GB RAM
# PCIe: Coral Edge TPU, Intel X710 10GbE SFP+ (dual), Intel I226-V/LM 2.5GbE (×2)
# NVMe: Kingston OM8PGP4 1TB (boot), 2× Lexar NM790 4TB (data)
# USB: Samsung T5 SSD, HubZ Smart Home Controller (Z-Wave + Zigbee), MediaTek MT7922 WiFi/BT
{ lib, modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # Boot loader (GRUB, UEFI)
  boot.loader.grub = {
    enable     = true;
    device     = "nodev";
    efiSupport = true;
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint     = "/boot/efi";

  # Kernel / initrd
  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "uas" "sd_mod" "thunderbolt" ];
  boot.initrd.kernelModules          = [ "dm-snapshot" ];
  boot.kernelModules                 = [ "kvm-intel" "i915" "xe" "coretemp" "wireguard" "i40e" "igc" "cp210x" ];
  boot.extraModulePackages           = [];

  # CPU
  hardware.cpu.intel.updateMicrocode = true;
  powerManagement.cpuFreqGovernor    = lib.mkDefault "performance";

  # USB device rules: HubZ Z-Wave/Zigbee controller (Silicon Labs cp210x)
  services.udev.extraRules = ''
    # HubZ Smart Home Controller - Z-Wave (port 0) and Zigbee (port 1)
    SUBSYSTEM=="tty", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="8a2a", ATTRS{bInterfaceNumber}=="00", SYMLINK+="zwave", MODE="0660", GROUP="dialout"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="8a2a", ATTRS{bInterfaceNumber}=="01", SYMLINK+="zigbee", MODE="0660", GROUP="dialout"
  '';

  # Thunderbolt
  services.hardware.bolt.enable = true;

  # Firmware updates & thermal management (Intel-specific)
  services.thermald.enable = true;
  services.fwupd.enable    = true;
  services.fstrim.enable   = true;

  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion  = "24.11";
}

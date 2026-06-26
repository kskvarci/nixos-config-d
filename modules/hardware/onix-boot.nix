# AMD desktop boot configuration for onix.
#
# Systemd-boot with EFI variable access, AMD microcode updates.
{ ... }:
{
  nixos.modules.onix-boot = { ... }: {
    boot.loader.systemd-boot.enable      = true;
    boot.loader.efi.canTouchEfiVariables = true;
    hardware.cpu.amd.updateMicrocode     = true;

    system.stateVersion = "25.11";
  };
}

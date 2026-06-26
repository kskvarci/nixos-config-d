# Bluetooth support with USB adapter autosuspend workaround.
#
# Disables btusb autosuspend to prevent BT mouse disconnects on
# certain USB Bluetooth adapters.
{ ... }:
{
  nixos.modules.bluetooth = { ... }: {
    hardware.bluetooth.enable      = true;
    hardware.bluetooth.powerOnBoot = true;
    services.blueman.enable        = true;

    # Prevent autosuspend on btusb — fixes intermittent BT mouse dropouts.
    boot.extraModprobeConfig = ''
      options btusb enable_autosuspend=0
    '';
  };
}

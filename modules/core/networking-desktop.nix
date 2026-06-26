# Desktop networking via NetworkManager.
#
# Used by inix and onix for DHCP + Wi-Fi management.
# The server (enix) uses systemd-networkd instead.
{ ... }:
{
  nixos.modules.networking-desktop = { ... }: {
    networking.networkmanager.enable = true;
  };
}

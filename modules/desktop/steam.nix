# Steam game client for onix (x86_64 + RTX 2070 Super).
#
# Enables 32-bit graphics support required by many games.
{ ... }:
{
  nixos.modules.steam = { ... }: {
    programs.steam.enable = true;

    # 32-bit OpenGL/Vulkan support required by most games
    hardware.graphics.enable32Bit = true;
  };
}

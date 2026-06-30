# Wayland desktop environment: niri compositor, greetd auto-login,
# PipeWire audio, XDG portals, fonts, and essential desktop utilities.
{ inputs, ... }:
{
  nixos.modules.desktop = { pkgs, ... }: {
    imports = [ inputs.niri.nixosModules.niri ];

    programs.niri.enable = true;

    # niri-flake binary cache only has x86_64 builds; no-op on aarch64.
    niri-flake.cache.enable = pkgs.stdenv.hostPlatform.system != "aarch64-linux";

    # Auto-login to niri session via greetd
    services.greetd = {
      enable   = true;
      settings = {
        initial_session = { command = "niri-session"; user = "kskvarci"; };
        default_session = { command = "niri-session"; user = "kskvarci"; };
      };
    };

    # XDG desktop portals (file picker, screen sharing, etc.)
    xdg.portal = {
      enable       = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config.common.default = "gtk";
    };

    # Desktop services
    services.udisks2.enable = true;
    services.upower.enable  = true;

    # PipeWire audio stack
    services.pipewire = {
      enable       = true;
      alsa.enable  = true;
      pulse.enable = true;
    };

    # Fonts
    fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];

    # Electron/Chromium Wayland native rendering
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    # Essential desktop utilities
    environment.systemPackages = with pkgs; [
      fuzzel
      wl-clipboard
      xwayland-satellite
    ];
  };
}

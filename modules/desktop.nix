# Wayland desktop: niri compositor, greetd auto-login, PipeWire audio,
# XDG portals, fonts, and essential desktop utilities.
{ inputs, ... }:
{
  nixos.modules.desktop = { pkgs, ... }: {
    imports = [ inputs.niri.nixosModules.niri ];

    programs.niri.enable = true;

    # niri-flake binary cache only has x86_64 builds; no-op on aarch64.
    niri-flake.cache.enable = pkgs.stdenv.hostPlatform.system != "aarch64-linux";

    services.greetd = {
      enable   = true;
      settings = {
        initial_session = { command = "niri-session"; user = "kskvarci"; };
        default_session = { command = "niri-session"; user = "kskvarci"; };
      };
    };

    xdg.portal = {
      enable       = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config.common.default = "gtk";
    };

    services.udisks2.enable = true;
    services.upower.enable  = true;

    services.pipewire = {
      enable     = true;
      alsa.enable = true;
      pulse.enable = true;
    };

    fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];

    environment.systemPackages = with pkgs; [
      fuzzel
      wl-clipboard
      git
    ];
  };
}

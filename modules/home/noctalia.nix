# Noctalia v5 panel/bar for niri.
{ ... }:
{
  hm.modules.noctalia = { ... }: {
    programs.noctalia = {
      enable         = true;
      systemd.enable = true;
      settings = {
        backdrop.enabled = true;
        bar.default = {
          background_opacity = 0.59;
          center             = [];
          end                = [ "tray" "volume" "battery" "notifications" "control-center" "session" ];
          margin_edge        = 0.0;
          margin_ends        = 0.0;
          padding            = 11;
          radius             = 13;
          radius_bottom_left  = 0;
          radius_bottom_right = 0;
          start              = [ "clock" "wallpaper" "workspaces" "weather" "cpu" ];
          thickness          = 28;
          widget_spacing     = 14;
        };
        shell = {
          settings_show_advanced = true;
          panel.transparency_mode = "soft";
        };
        theme = {
          builtin = "Ayu";
          source  = "wallpaper";
          templates = {
            builtin_ids   = [ "alacritty" "btop" "gtk3" "gtk4" "kcolorscheme" "kitty" "niri" "qt" ];
            community_ids = [ "obsidian" "vscode" "yazi" ];
          };
        };
        weather = {
          address = "raleigh, nc";
          unit    = "imperial";
        };
        widget.clock.format = "{:%-I:%M %p}";
      };
    };
  };
}

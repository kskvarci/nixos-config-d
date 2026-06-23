# Kitty terminal emulator.
{ ... }:
{
  hm.modules.terminal = { ... }: {
    programs.kitty = {
      enable = true;
      font = {
        name = "JetBrainsMono Nerd Font";
        size = 12;
      };
      settings = {
        window_padding_width    = 12;
        background_opacity      = "0.4";
        background_blur         = 20;
        hide_window_decorations = "yes";
        copy_on_select          = "yes";
        cursor_shape            = "block";
        cursor_blink_interval   = 1;
        cursor_trail            = 200;
        enable_audio_bell       = "no";
        scrollback_lines        = 3000;
        strip_trailing_spaces   = "smart";
        tab_bar_style           = "powerline";
        tab_bar_align           = "left";
        shell_integration       = "enabled";
      };
      keybindings = {
        "ctrl+shift+n" = "new_window";
        "ctrl+t"       = "new_tab";
        "ctrl+plus"    = "change_font_size all +1.0";
        "ctrl+minus"   = "change_font_size all -1.0";
        "ctrl+0"       = "change_font_size all 0";
      };
      extraConfig = "mouse_map right click ungrabbed paste_from_clipboard";
    };
  };
}

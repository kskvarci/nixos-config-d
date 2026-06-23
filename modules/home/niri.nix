# niri compositor config — shared base KDL plus per-host output/display settings.
{ ... }:
{
  hm.modules.niri = { osConfig, ... }:
  let
    hostNiriConfig = {
      inix = ''
        output "eDP-1" {
            mode "2560x1664@60.000"
            scale 2.0
        }
        spawn-at-startup "brightnessctl" "--device=kbd_backlight" "set" "5%"
      '';
      onix = ''
        output "HDMI-A-1" {
            scale 1.33
        }
      '';
    };
    hostname = osConfig.networking.hostName;
  in
  {
    home.file.".config/niri/config.kdl".text =
      builtins.readFile ./niri-base.kdl
      + "\n// ─── Host-specific (${hostname}) ───\n"
      + (hostNiriConfig.${hostname} or "");
  };
}

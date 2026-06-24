# User packages.
{ ... }:
{
  hm.modules.packages = { pkgs, ... }:
  let
    ratune = pkgs.callPackage ../../pkgs/ratune.nix {};
  in
  {
    home.packages = with pkgs; [
      # Browsers & communication
      brave
      firefox
      signal-desktop

      # Productivity
      obsidian
      vscodium
      github-copilot-cli

      # Music & audio
      picard
      ratune
      easyeffects

      # CLI
      fastfetch
      neovim
      yazi
      gh
      go
      nodejs
      nh
      azure-cli

      # VPN — NM secret agent needed for OpenConnect auth-dialog / sso-mib flow
      networkmanagerapplet
    ];
  };
}

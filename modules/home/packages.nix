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

      # Languages / runtimes
      go
      nodejs
      python3

      # CLI
      fastfetch
      neovim
      yazi
      gh
      nh
      azure-cli

      # VPN — NM secret agent needed for OpenConnect auth-dialog / sso-mib flow
      networkmanagerapplet
    ];
  };
}

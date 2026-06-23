# Home-manager identity: username, home directory, and state version.
{ ... }:
{
  hm.modules.base = { ... }: {
    home.username      = "kskvarci";
    home.homeDirectory = "/home/kskvarci";
    home.stateVersion  = "25.05";
  };
}

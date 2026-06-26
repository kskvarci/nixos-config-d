# Enix server user extensions.
#
# Adds server-specific groups (media for containers, render for GPU,
# dialout for serial devices like Coral/Z-Wave).
# The base user is defined in core/base.nix; this module extends it.
{ ... }:
{
  nixos.modules.server-users = { lib, pkgs, ... }: {
    users.mutableUsers = true;

    # Extend the base user with server-specific groups
    users.users.kskvarci = {
      uid         = lib.mkForce 1000;
      extraGroups = lib.mkForce [ "wheel" "media" "video" "render" "dialout" "cdrom" ];
    };

    # Shared group for media file ownership (containers run as this GID)
    users.groups.media = { gid = 1001; };
  };
}

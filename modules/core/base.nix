# Core system settings shared across ALL hosts (desktops and server).
#
# Provides: locale, timezone, Nix settings (flakes, gc, cachix),
# primary user account, fish shell, and SSH.
{ ... }:
{
  nixos.modules.base = { pkgs, lib, ... }: {
    # Allow unfree packages (firmware, drivers, etc.)
    nixpkgs.config.allowUnfree = true;

    # Nix daemon settings
    nix = {
      settings = {
        experimental-features   = [ "nix-command" "flakes" ];
        trusted-users           = [ "root" "@wheel" ];
        auto-optimise-store     = true;
        extra-substituters      = [ "https://noctalia.cachix.org" ];
        extra-trusted-public-keys = [
          "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
        ];
      };
      gc = {
        automatic = true;
        dates     = "weekly";
        options   = "--delete-older-than 14d";
      };
    };

    # Keep at most 10 boot entries to avoid /boot filling up
    boot.loader.systemd-boot.configurationLimit = 10;

    # IPv6 disabled on home network
    networking.enableIPv6 = false;

    # Locale & timezone
    time.timeZone      = "America/New_York";
    i18n.defaultLocale = "en_US.UTF-8";

    # Minimal system packages available everywhere
    environment.systemPackages = [ pkgs.vim pkgs.git ];

    # Primary user account
    users.users.kskvarci = {
      isNormalUser    = true;
      extraGroups     = [ "wheel" "networkmanager" "video" ];
      initialPassword = "changeme";
      shell           = pkgs.fish;
    };

    programs.fish.enable = true;

    # SSH hardened defaults (hosts can override with mkForce or higher priority)
    services.openssh = {
      enable   = true;
      settings = {
        PasswordAuthentication = lib.mkDefault false;
        PermitRootLogin        = lib.mkDefault "no";
      };
    };
  };
}

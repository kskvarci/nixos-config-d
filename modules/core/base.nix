# Core system settings shared across ALL hosts (desktops and server).
#
# Provides: locale, timezone, Nix settings (flakes, gc, cachix),
# primary user account, fish shell, and SSH.
{ ... }:
{
  nixos.modules.base = { pkgs, lib, inputs, ... }: {
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
    environment.systemPackages = [
      pkgs.vim
      pkgs.git
      inputs.deploy-rs.packages.${pkgs.stdenv.hostPlatform.system}.deploy-rs
    ];

    # Primary user account
    users.users.kskvarci = {
      isNormalUser    = true;
      extraGroups     = [ "wheel" "networkmanager" "video" ];
      initialPassword = "changeme";
      shell           = pkgs.fish;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGdgPO8UneAunK8wqM8DoMlLLcomVLgkjP2wb6aneqhw inix"
      ];
    };

    # Passwordless sudo for wheel (required for deploy-rs)
    security.sudo.wheelNeedsPassword = false;

    # Allow root SSH with key (for initial deploys and emergencies)
    users.users.root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGdgPO8UneAunK8wqM8DoMlLLcomVLgkjP2wb6aneqhw inix"
    ];

    programs.fish.enable = true;

    # SSH — password auth enabled, root login allowed for initial setup
    services.openssh = {
      enable   = true;
      settings = {
        PasswordAuthentication = lib.mkDefault true;
        PermitRootLogin        = lib.mkDefault "yes";
      };
    };
  };
}

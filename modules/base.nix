# Core system settings shared across all hosts.
{ ... }:
{
  nixos.modules.base = { pkgs, ... }: {
    nixpkgs.config.allowUnfree = true;

    nix = {
      settings = {
        experimental-features = [ "nix-command" "flakes" ];
        trusted-users          = [ "root" "@wheel" ];
        auto-optimise-store    = true;
        extra-substituters     = [ "https://noctalia.cachix.org" ];
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

    boot.loader.systemd-boot.configurationLimit = 10;

    networking.enableIPv6 = false;

    time.timeZone      = "America/New_York";
    i18n.defaultLocale = "en_US.UTF-8";

    environment.sessionVariables.NIXOS_OZONE_WL = "1";
    environment.systemPackages = [ pkgs.vim ];

    users.users.kskvarci = {
      isNormalUser    = true;
      extraGroups     = [ "wheel" "networkmanager" "video" ];
      initialPassword = "changeme";
      shell           = pkgs.fish;
    };

    programs.fish.enable = true;

    services.openssh = {
      enable   = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin        = "no";
      };
    };
  };
}

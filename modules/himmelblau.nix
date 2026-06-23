# Azure Entra ID (formerly AAD) authentication via himmelblau.
{ inputs, ... }:
{
  nixos.modules.himmelblau = { config, lib, pkgs, ... }: {
    imports = [ inputs.himmelblau.nixosModules.himmelblau ];

    services.himmelblau = {
      enable      = true;
      pamServices = [ "passwd" "login" "systemd-user" ];
      settings = {
        domain                                = [ "microsoft.com" ];
        join_type                             = "register";
        hsm_type                              = "soft";
        connection_timeout                    = 120;
        local_groups                          = [ "users" ];
        home_attr                             = "cn";
        home_alias                            = "cn";
        use_etc_skel                          = true;
        apply_policy                          = true;
        enable_experimental_mfa               = true;
        enable_experimental_passwordless_fido = true;
      };
    };

    # Prevent himmelblau from prompting Hello PIN on sudo.
    security.pam.services.sudo.rules.auth.himmelblau.enable    = false;
    security.pam.services.sudo.rules.account.himmelblau.enable = false;
    security.pam.services.sudo.rules.session.himmelblau.enable = false;

    # FIDO2 / YubiKey support for passwordless auth.
    services.udev.packages = [ pkgs.yubikey-personalization ];
    services.pcscd.enable  = true;

    environment.systemPackages = [
      config.services.himmelblau.package
      pkgs.libfido2
      pkgs.yubikey-manager
    ];

    systemd.services.himmelblaud.environment.SSL_CERT_FILE =
      "/etc/ssl/certs/ca-certificates.crt";
    systemd.services.himmelblaud-tasks.environment.SSL_CERT_FILE =
      "/etc/ssl/certs/ca-certificates.crt";

    systemd.services.himmelblaud-tasks.serviceConfig.RestrictAddressFamilies =
      lib.mkForce [ "AF_UNIX" "AF_INET" "AF_INET6" "AF_NETLINK" ];

    systemd.services.himmelblaud-tasks.serviceConfig.ReadWritePaths = lib.mkForce [
      "/home"
      "/var/run/himmelblaud"
      "/tmp"
      "/etc/krb5.conf.d"
      "/etc"
      "/var/lib"
      "/var/cache/nss-himmelblau"
      "/var/cache/himmelblau-policies"
    ];

    systemd.tmpfiles.rules = [
      "d /var/cache/himmelblau-policies 0755 root root -"
      "d /etc/cron.d 0755 root root -"
    ];

    # Native messaging host for Entra SSO in Chromium/Brave.
    environment.etc."brave/native-messaging-hosts/linux_entra_sso.json".source =
      "${config.services.himmelblau.package}/lib/chromium/native-messaging-hosts/linux_entra_sso.json";

    # Fake Ubuntu os-release — required for himmelblau device compliance checks.
    environment.etc."himmelblau/fake-os-release".text = ''
      NAME="Ubuntu"
      VERSION="22.04.4 LTS (Jammy Jellyfish)"
      ID=ubuntu
      ID_LIKE=debian
      PRETTY_NAME="Ubuntu 22.04.4 LTS"
      VERSION_ID="22.04"
      HOME_URL="https://www.ubuntu.com/"
      SUPPORT_URL="https://help.ubuntu.com/"
      BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
      UBUNTU_CODENAME=jammy
      VERSION_CODENAME=jammy
    '';

    systemd.services.himmelblaud-tasks.serviceConfig.BindReadOnlyPaths = [
      "/etc/himmelblau/fake-os-release:/etc/os-release"
    ];
    systemd.services.himmelblaud.serviceConfig.BindReadOnlyPaths = [
      "/etc/himmelblau/fake-os-release:/etc/os-release"
    ];

    environment.etc."himmelblau/user-map".text = ''
      kskvarci:keskvarc@microsoft.com
    '';
  };
}

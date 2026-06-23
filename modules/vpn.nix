# Microsoft corporate VPN via OpenConnect + GlobalProtect protocol.
#
# networkmanager-openconnect from nixpkgs 1.2.10 already supports
# --with-sso-mib in upstream configure.ac; this overlay just enables it
# so the plugin uses himmelblau's identity broker for Entra Conditional
# Access SSO (silent token acquisition, browser popup as fallback).
#
# Gateway: redmond.msftvpn-alt.ras.microsoft.com (GlobalProtect)
{ ... }:
{
  nixos.modules.vpn = { pkgs, ... }: {
    nixpkgs.overlays = [
      (final: prev: {
        sso-mib = prev.callPackage ../pkgs/sso-mib.nix {};

        networkmanager-openconnect = prev.networkmanager-openconnect.overrideAttrs (old: {
          buildInputs    = old.buildInputs ++ [ final.sso-mib ];
          configureFlags = old.configureFlags ++ [ "--with-sso-mib=yes" ];
        });
      })
    ];

    networking.networkmanager.plugins = [ pkgs.networkmanager-openconnect ];
  };
}

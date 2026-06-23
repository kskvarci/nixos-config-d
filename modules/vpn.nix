# Microsoft corporate VPN via OpenConnect + GlobalProtect protocol.
#
# networkmanager-openconnect main branch adds --with-sso-mib support;
# the 1.2.10 release tarball predates it, so we build from git HEAD.
# sso-mib is already packaged in pkgs/sso-mib.nix.
#
# Gateway: redmond.msftvpn-alt.ras.microsoft.com (GlobalProtect)
{ ... }:
{
  nixos.modules.vpn = { pkgs, ... }: {
    nixpkgs.overlays = [
      (final: prev: {
        sso-mib = prev.callPackage ../pkgs/sso-mib.nix {};

        networkmanager-openconnect = prev.networkmanager-openconnect.overrideAttrs (old: {
          # main branch has --with-sso-mib; 1.2.10 release tarball predates it
          src = prev.fetchFromGitLab {
            domain = "gitlab.gnome.org";
            owner  = "GNOME";
            repo   = "NetworkManager-openconnect";
            rev    = "bcdb09b22f99455cf932b8d0062189b6a297c90c";
            hash   = "sha256-n8+g13RHAwC7uO1VZTqblATk88LbcNt5FWD0wornyMg=";
          };

          # Git archive has configure.ac but no generated configure script.
          nativeBuildInputs = (old.nativeBuildInputs or []) ++ [
            prev.autoreconfHook
          ];

          # Replace hardcoded binary paths inline (avoids fragile patch line counts).
          postPatch = ''
            substituteInPlace src/nm-openconnect-service.c \
              --replace-fail '"/usr/sbin/openconnect",' '"${prev.openconnect}/bin/openconnect",' \
              --replace-fail '"/sbin/modprobe tun"' '"${prev.kmod}/bin/modprobe tun"'
            sed -i '/"\/usr\/local\/bin\/openconnect",/d;/"\/usr\/local\/sbin\/openconnect",/d' \
              src/nm-openconnect-service.c
          '';

          # Drop the replaceVars-based fix-paths patch; handled by postPatch above.
          patches = [];

          buildInputs    = old.buildInputs ++ [ final.sso-mib ];
          configureFlags = old.configureFlags ++ [ "--with-sso-mib=yes" ];
        });
      })
    ];

    networking.networkmanager.plugins = [ pkgs.networkmanager-openconnect ];
  };
}

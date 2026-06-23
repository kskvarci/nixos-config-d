# Azure Entra ID / AAD VPN via OpenVPN + NetworkManager.
#
# Provides two patched packages via a nixpkgs overlay:
#
#   openvpn        — master branch + Gerrit PR #1622 (TLS record-sized buffers for
#                    key method 2 exchange, required to pass long JWT tokens to the
#                    Azure VPN gateway without silent truncation).
#
#   networkmanager-openvpn — entra_auth branch (commit 862d469e) which adds Entra ID
#                    auth support via the sso-mib library (talks to himmelblau's
#                    Microsoft Identity Broker over DBus to obtain a JIT use-once token).
#
# See also: https://gerrit.openvpn.net/c/openvpn/+/1622
#           https://gitlab.gnome.org/bluca/NetworkManager-openvpn/-/commits/entra_auth
{ ... }:
{
  nixos.modules.vpn = { pkgs, lib, ... }: {
    nixpkgs.overlays = [
      (final: prev:
        let
          sso-mib = prev.callPackage ../pkgs/sso-mib.nix {};
        in {
          inherit sso-mib;

          # OpenVPN from master (includes management proto v6 support, commit 49ff16dd)
          # plus Gerrit PR #1622 applied on top (TLS record-sized buffers so that JWT
          # tokens >2048 bytes aren't silently truncated during key exchange).
          openvpn = prev.openvpn.overrideAttrs (old: {
            version = "master-97ec6337";

            src = prev.fetchFromGitHub {
              owner = "OpenVPN";
              repo  = "openvpn";
              rev   = "97ec63372ab354ad48c89e73d1e37715679370ba";
              hash  = "sha256-IFk4nqZ94lsfGbTaZXVyQh5hOiy0WsXhdoXJki3P3qw=";
            };

            patches = [ ../pkgs/patches/openvpn-1622-tls-record-buffers.patch ];

            # Git snapshot has configure.ac but no generated configure script,
            # and no pre-built man pages (needs rst2man from docutils).
            nativeBuildInputs = (old.nativeBuildInputs or []) ++ [
              prev.autoreconfHook
              prev.python3Packages.docutils
            ];
          });

          # NetworkManager-openvpn from the entra_auth branch, which:
          #   1. Supports openvpn management proto v6 for long passwords (>255 chars).
          #   2. Adds Entra ID auth type that uses sso-mib to get a JIT JWT token from
          #      the Microsoft Identity Broker (himmelblau) via DBus.
          #   3. Supports inline hex TLS-Auth secrets (as shipped in Azure VPN profiles).
          networkmanager-openvpn = prev.networkmanager-openvpn.overrideAttrs (old: {
            version = "1.12.5-entra";

            src = prev.fetchFromGitLab {
              domain = "gitlab.gnome.org";
              owner  = "bluca";
              repo   = "NetworkManager-openvpn";
              rev    = "862d469eef7325b2c9c08ea3b6347a7fb7e5c787";
              hash   = "sha256-zX2jo3vyTBQrJvPjpIjoPiji/Xz0g5AB3s3PxJErwI0=";
            };

            # Re-apply the Nix path-fixup inline, wiring in our patched openvpn
            # and the system kmod. Uses postPatch to avoid fragile patch line counts.
            patches = [];
            postPatch = ''
              substituteInPlace properties/nm-openvpn-editor.c \
                --replace-fail '"/usr/sbin/openvpn",' '"${final.openvpn}/bin/openvpn",'
              sed -i '/"\/sbin\/openvpn",/d' properties/nm-openvpn-editor.c

              substituteInPlace src/nm-openvpn-service.c \
                --replace-fail '"/usr/sbin/openvpn",' '"${final.openvpn}/bin/openvpn",' \
                --replace-fail '"/sbin/modprobe tun"' '"${prev.kmod}/bin/modprobe tun"'
              sed -i '/"\/sbin\/openvpn",/d;/"\/usr\/local\/sbin\/openvpn",/d' \
                src/nm-openvpn-service.c
            '';

            # GitLab archive has configure.ac but no generated configure script,
            # and UI files need gtk4-builder-tool to convert GTK3→GTK4 at build
            # time (release tarballs ship them pre-converted).
            nativeBuildInputs = (old.nativeBuildInputs or []) ++ [
              prev.autoreconfHook
              prev.gtk4
            ];

            buildInputs    = old.buildInputs ++ [ sso-mib ];
            configureFlags = old.configureFlags ++ [ "--with-sso-mib=yes" ];
          });
        })
    ];

    # Install the patched NM-openvpn VPN backend plugin.
    networking.networkmanager.plugins = [ pkgs.networkmanager-openvpn ];
  };
}

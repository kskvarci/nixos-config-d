# Microsoft corporate VPN via OpenConnect + GlobalProtect protocol.
#
# networkmanager-openconnect main branch adds --with-sso-mib support;
# the 1.2.10 release tarball predates it, so we build from git HEAD.
# sso-mib is already packaged in pkgs/sso-mib.nix.
#
# Gateway: redmond.msftvpn-alt.ras.microsoft.com (GlobalProtect)
{ ... }:
let
  # Split-tunnel routes: GP-pushed corp routes + Microsoft public service ranges
  # from MSFT-AzVPN-Manual.xml includeroutes. Applied only while VPN is active.
  vpnRoutes = "2.22.146.146/32,2.22.146.152/32,3.4.0.0/16,4.144.0.0/12,4.160.0.0/12,4.176.0.0/12,4.192.0.0/10,5.153.9.204/32,7.28.0.0/14,9.160.0.0/16,9.163.0.0/16,9.169.0.0/16,9.223.0.0/16,9.234.0.0/16,10.0.0.0/8,13.64.0.0/11,13.96.0.0/13,13.104.0.0/13,20.0.0.0/11,20.33.0.0/16,20.36.0.0/14,20.40.0.0/13,20.48.0.0/12,20.64.0.0/10,20.135.0.0/16,20.136.0.0/16,20.140.0.0/15,20.143.0.0/16,20.150.0.0/15,20.152.0.0/15,20.157.0.0/16,20.158.0.0/15,20.160.0.0/12,20.180.0.0/14,20.184.0.0/13,20.192.0.0/10,21.2.24.0/21,23.96.0.0/13,25.0.0.0/8,28.28.0.0/14,29.24.0.0/14,40.64.0.0/13,40.74.0.0/15,40.76.0.0/14,40.80.0.0/12,40.96.0.0/13,40.112.0.0/13,40.120.0.0/14,40.124.0.0/16,40.125.0.0/17,40.126.0.0/18,40.126.128.0/17,40.127.0.0/16,48.192.0.0/11,50.85.0.0/16,51.4.0.0/15,51.8.0.0/16,51.11.0.0/16,51.12.0.0/15,51.18.0.0/16,51.53.0.0/16,51.54.0.0/15,51.103.0.0/16,51.104.0.0/15,51.107.0.0/16,51.116.0.0/16,51.120.0.0/16,51.124.0.0/16,51.132.0.0/16,51.136.0.0/15,51.138.0.0/16,51.140.0.0/14,51.144.0.0/15,52.96.0.0/12,52.120.0.0/14,52.125.128.0/20,52.126.0.0/15,52.136.0.0/13,52.146.0.0/15,52.148.0.0/14,52.152.0.0/13,52.160.0.0/11,52.224.0.0/11,57.150.0.0/15,57.152.0.0/13,57.160.0.0/12,64.4.8.0/24,64.236.0.0/16,65.52.0.0/14,65.53.0.0/16,65.54.0.0/15,65.55.0.0/16,66.119.0.0/16,68.154.0.0/15,68.210.0.0/15,68.218.0.0/15,68.220.0.0/15,70.37.0.0/17,70.37.160.0/21,70.153.128.0/19,70.156.0.0/18,70.157.0.0/19,72.144.0.0/14,72.152.0.0/16,72.153.0.0/16,72.154.0.0/16,74.144.0.0/14,74.160.0.0/14,74.176.0.0/14,74.224.0.0/14,74.234.0.0/15,74.240.0.0/14,74.248.0.0/15,85.210.0.0/15,85.212.0.0/16,86.232.0.0/16,90.72.0.0/16,94.245.64.0/19,98.64.0.0/14,98.70.0.0/15,100.64.0.0/10,102.37.0.0/16,102.133.0.0/16,104.40.0.0/13,104.208.0.0/13,108.140.0.0/14,108.174.0.0/20,128.24.0.0/16,128.85.0.0/16,128.203.0.0/16,128.251.0.0/16,130.33.0.0/16,130.107.0.0/16,130.131.0.0/16,130.213.0.0/16,131.107.0.0/16,131.228.0.0/16,131.145.0.0/16,131.163.0.0/17,131.253.12.0/23,131.253.32.0/20,132.164.0.0/16,132.196.0.0/16,132.220.0.0/16,134.33.0.0/16,134.112.0.0/17,134.138.128.0/17,134.149.0.0/17,134.170.148.0/22,134.170.192.0/21,134.170.220.0/22,135.10.0.0/15,135.18.0.0/16,135.114.0.0/15,135.116.0.0/14,135.120.0.0/15,135.130.0.0/17,135.149.0.0/16,135.216.0.0/14,135.220.0.0/15,135.222.0.0/15,135.224.0.0/15,135.226.0.0/16,135.232.0.0/14,135.236.0.0/15,137.116.0.0/15,137.135.0.0/16,138.91.0.0/16,141.251.0.0/16,145.133.0.0/16,145.190.0.0/16,145.191.0.0/16,147.117.164.0/22,147.243.0.0/16,149.126.74.108/32,150.171.0.0/16,157.54.0.0/16,157.55.0.0/15,157.56.0.0/14,157.60.0.0/16,158.23.0.0/16,163.228.8.4/32,167.105.0.0/16,167.220.0.0/16,168.61.0.0/16,168.62.0.0/15,172.16.0.0/12,172.128.0.0/10,172.176.0.0/16,172.192.0.0/12,172.200.0.0/13,172.208.0.0/13,184.28.188.16/32,190.98.140.88/32,190.98.140.105/32,191.232.0.0/13,192.230.67.108/32,192.230.77.108/32,192.230.79.108/32,193.149.64.0/19,195.90.94.0/27,198.180.96.0/23,198.181.121.64/26,198.181.125.64/26,199.30.16.0/24,199.83.131.108/32,199.83.132.108/32,199.117.103.147/32,202.60.62.100/31,202.60.62.104/32,202.60.63.100/32,202.222.84.88/32,202.222.84.240/28,203.191.35.22/32,203.191.35.24/31,204.77.249.216/29,207.46.0.0/16,207.68.174.0/24,209.199.0.0/16,209.207.193.128/28,209.207.193.160/27,209.207.193.224/27,209.207.232.192/28,212.132.0.0/19,213.199.128.0/20,213.199.168.0/23,213.199.179.20/32,216.251.141.226/32,217.177.96.0/19";
in
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

    # opensc provides opensc-pkcs11.so for YubiKey PIV slot 9A cert auth
    environment.systemPackages = [
      pkgs.opensc

      # vpn-connect: recreates the NM connection fresh on every invocation so
      # sso-mib always acquires a new PRT SSO cookie (cookies are short-lived).
      # Routes are VPN-scoped — active only while the tunnel is up.
      (pkgs.writeShellScriptBin "vpn-connect" ''
        nmcli connection delete MSFT-CorpVPN 2>/dev/null
        nmcli connection add \
          type vpn vpn-type openconnect \
          con-name "MSFT-CorpVPN" \
          -- \
          vpn.data "gateway=redmond.msftvpn-alt.ras.microsoft.com, protocol=gp, entra_conditional_access=yes" \
          ipv4.routes "${vpnRoutes}" \
          ipv4.never-default yes
        nmcli connection up MSFT-CorpVPN
      '')
    ];

    # Clear cached VPN cookie on disconnect so sso-mib acquires a fresh one
    # on every reconnect (PRT SSO cookies are short-lived).
    networking.networkmanager.dispatcherScripts = [{
      source = pkgs.writeText "clear-vpn-cookie" ''
        #!/bin/sh
        CONN_ID="$2"
        ACTION="$1"
        if [ "$ACTION" = "vpn-up" ]; then
          # The GP gateway pushes 192.168.0.0/16 via tun0 (metric 50), which beats
          # the local LAN kernel route (metric 100) and breaks LAN connectivity.
          # Remove it so local 192.168.x.x traffic stays on the LAN interface.
          ${pkgs.iproute2}/bin/ip route del 192.168.0.0/16 dev tun0 2>/dev/null || true
        fi
        if [ "$ACTION" = "vpn-down" ] || [ "$ACTION" = "connectivity-change" ]; then
          nmcli --fields vpn.secrets connection show "$CONN_ID" 2>/dev/null | \
            grep -q "gateway-cookies" && \
            nmcli connection modify "$CONN_ID" vpn.secrets "" 2>/dev/null
        fi
      '';
      type = "basic";
    }];
  };
}

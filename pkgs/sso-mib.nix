# C library to interact with the Microsoft Device Broker (MIB) for SSO tokens via DBus.
# Required by the NetworkManager-openvpn entra_auth branch for Azure VPN authentication.
{ lib, stdenv, fetchFromGitHub, meson, ninja, pkg-config, glib, json-glib, util-linux }:

stdenv.mkDerivation rec {
  pname = "sso-mib";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "siemens";
    repo = "sso-mib";
    rev = "v${version}";
    hash = "sha256-qPhGVoSSRm7FLD7Ja8RniTqN+sLK9jbO3ALXv6K/YVw=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    glib # provides gdbus-codegen for the identity-broker DBus binding
  ];

  # Propagated so that consumers (networkmanager-openvpn) can satisfy
  # sso-mib.pc's Requires: glib-2.0 gio-2.0 uuid when pkg-config resolves it.
  propagatedBuildInputs = [
    glib
    json-glib
    util-linux
  ];

  mesonFlags = [
    "-Dlibjwt=disabled" # only needed for the sso-mib CLI tool, not the library
  ];

  meta = with lib; {
    description = "C library to interact with the Microsoft Device Broker for SSO tokens via DBus";
    homepage = "https://github.com/siemens/sso-mib";
    license = with licenses; [ gpl2Plus lgpl21Plus mit ];
    platforms = platforms.linux;
  };
}

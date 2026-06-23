# Ratune — Subsonic/Navidrome TUI music client (not in nixpkgs).
{ lib, fetchFromGitHub, rustPlatform, pkg-config, openssl, alsa-lib, dbus }:

rustPlatform.buildRustPackage {
  pname = "ratune";
  version = "0.13.0";

  src = fetchFromGitHub {
    owner = "acmagn";
    repo = "ratune";
    rev = "v0.13.0";
    hash = "sha256-Fy0bX3s7+s+wrQ1YpqB/bWcFe/6YMpdlfWVQ2yRKR6c=";
  };

  cargoHash = "sha256-aqrYGUbaTMHfwqXY3CPSB9u4u3QVB6i+8JqhPimlevI=";
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl alsa-lib dbus ];

  meta = with lib; {
    description = "TUI music player for Subsonic-compatible servers";
    homepage = "https://github.com/acmagn/ratune";
    license = licenses.mit;
    mainProgram = "ratune";
  };
}

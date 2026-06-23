# niri overlay: skips the test suite when building niri from source.
# Applied on all hosts; on aarch64 the niri-flake cache is unavailable anyway
# so skipping tests avoids a long build.
{ ... }:
{
  nixos.modules.niri-overlay = { ... }: {
    nixpkgs.overlays = [
      (final: prev: {
        niri = prev.niri.overrideAttrs (_: { doCheck = false; });
      })
    ];
  };
}

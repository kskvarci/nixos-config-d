# Cachix binary cache configuration.
# WARN: the cachix/ directory entries may be overwritten by $ cachix use <name>
{ ... }:
{
  nixos.modules.cachix = { lib, ... }:
  let
    folder    = ../cachix;
    toImport  = name: _value: folder + ("/" + name);
    filterCaches = key: value: value == "regular" && lib.hasSuffix ".nix" key;
    cacheImports  = lib.mapAttrsToList toImport
      (lib.filterAttrs filterCaches (builtins.readDir folder));
  in
  {
    imports = cacheImports;
    nix.settings.extra-substituters = [ "https://cache.nixos.org/" ];
  };
}

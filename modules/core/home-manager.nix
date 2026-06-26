# Top-level module: declares hm.modules and wires all HM feature modules into
# NixOS via home-manager.sharedModules.  Stored as nixos.modules.home-manager so
# hosts can import it by name alongside their other feature modules.
{ config, lib, inputs, ... }:
{
  options.hm.modules = lib.mkOption {
    type    = lib.types.lazyAttrsOf lib.types.deferredModule;
    default = {};
  };

  # config.hm.modules is resolved at flake-parts eval time and captured in the
  # closure below — this is how cross-cutting values flow into lower-level evals.
  config.nixos.modules.home-manager = { ... }: {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    home-manager = {
      useGlobalPkgs   = true;
      useUserPackages = true;
      extraSpecialArgs = { inherit inputs; };
      sharedModules    =
        [ inputs.noctalia.homeModules.default ]
        ++ lib.attrValues config.hm.modules;
      # Empty attrset is enough — all config comes through sharedModules.
      users.kskvarci = {};
    };
  };
}

# Top-level module: declares the nixos.modules and nixos.configurations options,
# and builds flake.nixosConfigurations from them.
{ config, lib, inputs, ... }:
{
  options.nixos = {
    modules = lib.mkOption {
      type    = lib.types.lazyAttrsOf lib.types.deferredModule;
      default = {};
    };

    configurations = lib.mkOption {
      default = {};
      type = lib.types.lazyAttrsOf (lib.types.submodule {
        options = {
          system = lib.mkOption { type = lib.types.str; };
          module = lib.mkOption { type = lib.types.deferredModule; };
        };
      });
    };
  };

  config.flake.nixosConfigurations =
    lib.mapAttrs (name: cfg:
      inputs.nixpkgs.lib.nixosSystem {
        inherit (cfg) system;
        specialArgs = { inherit inputs; };
        modules     = [ cfg.module ];
      }
    ) config.nixos.configurations;
}

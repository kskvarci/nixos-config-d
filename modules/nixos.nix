# Top-level flake-parts module: defines the nixos.modules and nixos.configurations
# option namespaces, then wires them into flake.nixosConfigurations.
#
# Each file under modules/ registers named modules via nixos.modules.<name>.
# Host files compose those modules into nixos.configurations.<hostname>.modules.
{ config, lib, inputs, ... }:
{
  options.nixos = {
    # Named NixOS feature modules (e.g. nixos.modules.desktop, nixos.modules.vpn).
    # Each is a deferredModule — evaluated lazily only when a host includes it.
    modules = lib.mkOption {
      type    = lib.types.lazyAttrsOf lib.types.deferredModule;
      default = {};
      description = "Named NixOS modules that can be composed into host configurations.";
    };

    # Per-host configuration: system architecture + list of modules to compose.
    configurations = lib.mkOption {
      type = lib.types.lazyAttrsOf (lib.types.submodule {
        options = {
          system = lib.mkOption {
            type = lib.types.str;
            description = "System architecture (e.g. x86_64-linux, aarch64-linux).";
          };
          modules = lib.mkOption {
            type    = lib.types.listOf lib.types.deferredModule;
            default = [];
            description = "List of NixOS modules to compose for this host.";
          };
        };
      });
      default = {};
    };
  };

  # Build flake.nixosConfigurations from the declarations above.
  # Automatically injects networking.hostName from the attribute name.
  config.flake.nixosConfigurations =
    lib.mapAttrs (name: hostCfg:
      inputs.nixpkgs.lib.nixosSystem {
        system      = hostCfg.system;
        specialArgs = { inherit inputs; };
        modules     = hostCfg.modules ++ [
          { networking.hostName = lib.mkDefault name; }
        ];
      }
    ) config.nixos.configurations;
}

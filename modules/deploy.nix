# deploy-rs configuration for multi-host deployments.
#
# Usage:
#   deploy .#enix         — deploy to enix
#   deploy .#inix         — deploy to inix
#   deploy .#onix         — deploy to onix
#   deploy .              — deploy to all hosts
{ config, inputs, lib, ... }:
let
  deployPkgs = system: import inputs.nixpkgs {
    inherit system;
    overlays = [
      inputs.deploy-rs.overlays.default
      (self: super: {
        deploy-rs = {
          inherit (inputs.deploy-rs.packages.${system}) deploy-rs;
          inherit (super.deploy-rs) lib;
        };
      })
    ];
  };
in
{
  flake.deploy.nodes = {
    enix = {
      hostname = "192.168.1.34";
      sshUser = "kskvarci";
      profiles.system = {
        user = "root";
        path = (deployPkgs "x86_64-linux").deploy-rs.lib.activate.nixos
          config.flake.nixosConfigurations.enix;
      };
    };

    inix = {
      hostname = "localhost";
      sshUser = "kskvarci";
      profiles.system = {
        user = "root";
        path = (deployPkgs "aarch64-linux").deploy-rs.lib.activate.nixos
          config.flake.nixosConfigurations.inix;
      };
    };

    onix = {
      hostname = "onix";
      sshUser = "kskvarci";
      profiles.system = {
        user = "root";
        path = (deployPkgs "x86_64-linux").deploy-rs.lib.activate.nixos
          config.flake.nixosConfigurations.onix;
      };
    };
  };

  flake.checks = lib.mapAttrs
    (system: deployLib: deployLib.deployChecks inputs.self.deploy)
    inputs.deploy-rs.lib;
}

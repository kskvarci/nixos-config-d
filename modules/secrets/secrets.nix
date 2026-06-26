# Secrets management via sops-nix.
#
# Encrypts secrets at rest using age keys. The host's age key lives at
# /var/lib/sops-nix/key.txt (generated once, never committed to git).
#
# To add secrets:
#   1. Create/edit secrets/secrets.yaml with sops
#   2. Reference them in modules: sops.secrets.my-secret.sopsFile = ...
{ inputs, ... }:
{
  nixos.modules.secrets = { ... }: {
    imports = [ inputs.sops-nix.nixosModules.sops ];

    sops.defaultSopsFile = ../../secrets/secrets.yaml;
    sops.age.keyFile     = "/var/lib/sops-nix/key.txt";
  };
}

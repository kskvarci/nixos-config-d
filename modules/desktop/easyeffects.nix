# EasyEffects audio EQ configuration for onix.
#
# Deploys a pre-tuned EQ preset for Hifiman Sundara headphones via JDS Atom DAC.
# Config is copied (not symlinked) so EasyEffects can write runtime state.
{ inputs, ... }:
{
  nixos.modules.easyeffects = { ... }: {
    home-manager.users.kskvarci.home.activation.easyeffectsConfig =
      inputs.home-manager.lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p "$HOME/.config/easyeffects/db"
        for f in easyeffectsrc equalizerrc; do
          install -m644 ${../../hosts/onix/easyeffects}/$f \
            "$HOME/.config/easyeffects/db/$f"
        done
      '';
  };
}

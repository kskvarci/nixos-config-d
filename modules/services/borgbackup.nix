# Borg backup to Samsung T5 USB SSD
{
  nixos.modules.borgbackup = {
    services.borgbackup.jobs.cumulus = {
      paths = [
        "/data/d2/photos"
        "/data/d2/homevideo"
        "/data/d2/fileshare"
        "/data/d1/appdata"
      ];
      repo = "/mnt/t5/borgrepo1";
      encryption = {
        mode = "repokey";
        passCommand = "cat /run/secrets/borg-passphrase";
      };
      compression = "auto,zstd";
      startAt = "daily";
      prune.keep = {
        daily = 7;
        weekly = 4;
        monthly = 12;
      };
    };

    # sops-nix secret for borg passphrase
    sops.secrets.borg-passphrase = {
      sopsFile = ../../secrets/secrets.yaml;
    };
  };
}
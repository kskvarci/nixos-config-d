# Persistent SMB/CIFS mounts for shares on 192.168.1.34.
#
# Credentials file: /etc/smb-credentials
# Format (plain text, chmod 600, owned by root):
#   username=youruser
#   password=yourpassword
#   domain=WORKGROUP   # optional
{ ... }:
{
  nixos.modules.smb-mounts = { pkgs, ... }:
  let
    server = "192.168.1.34";

    commonOptions = [
      "credentials=/etc/smb-credentials"
      "uid=1000"
      "gid=100"
      "file_mode=0644"
      "dir_mode=0755"
      "vers=3.0"
      "nofail"
      "_netdev"
      "noauto"
      "x-systemd.automount"
      "x-systemd.idle-timeout=60"
    ];

    mkSmbMount = share: {
      device  = "//${server}/${share}";
      fsType  = "cifs";
      options = commonOptions;
    };
  in
  {
    environment.systemPackages = [ pkgs.cifs-utils ];

    fileSystems."/mnt/fileshare"      = mkSmbMount "fileshare";
    fileSystems."/mnt/music"          = mkSmbMount "music";
    fileSystems."/mnt/musicdownloads" = mkSmbMount "musicdownloads";
  };
}

# Samba file sharing
{
  nixos.modules.samba = {pkgs, ...}: {
    services.samba = {
      enable = true;
      openFirewall = true;
      settings = {
        global = {
          workgroup = "WORKGROUP";
          "server string" = "cumulus";
          "server role" = "standalone server";
          "map to guest" = "bad user";
          "usershare allow guests" = "yes";
          logging = "file";
          "max log size" = "1000";
        };
        photos = {
          path = "/data/d2/photos";
          "read only" = "no";
          browseable = "yes";
        };
        homevideo = {
          path = "/data/d2/homevideo";
          "read only" = "no";
          browseable = "yes";
        };
        fileshare = {
          path = "/data/d2/fileshare";
          "read only" = "no";
          browseable = "yes";
        };
        music = {
          path = "/data/d1/music";
          "read only" = "no";
          browseable = "yes";
        };
        musicdownloads = {
          path = "/data/d1/musicdownloads";
          "read only" = "no";
          browseable = "yes";
        };
        photoshare = {
          path = "/data/d1/photoshare";
          "read only" = "no";
          browseable = "yes";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = "photoshare";
        };
      };
    };

    # Enable WINS/NetBIOS name resolution
    services.samba-wsdd = {
      enable = true;
      openFirewall = true;
    };
  };
}

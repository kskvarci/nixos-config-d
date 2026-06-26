# Enix filesystems: LVM root, EFI, data disks, and swap.
#
# d1/d2 are NVMe data disks for media storage; t5 is a portable USB SSD.
{ ... }:
{
  nixos.modules.storage-enix = { ... }: {
    fileSystems."/" = {
      device = "/dev/disk/by-uuid/32e648c0-9c59-48af-8c70-871dd1b5fcc2";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/b88bdb16-fa78-479b-a613-07b77b45b937";
      fsType = "ext4";
    };

    fileSystems."/boot/efi" = {
      device = "/dev/disk/by-uuid/F11A-4FF4";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

    fileSystems."/data/d1" = {
      device = "/dev/disk/by-uuid/831ac6a7-9cd8-40d1-bd62-39305a9617dc";
      fsType = "ext4";
      options = [ "nofail" ];
    };

    fileSystems."/data/d2" = {
      device = "/dev/disk/by-uuid/58c6235e-83ce-4cb8-8481-44c3c2cdef55";
      fsType = "ext4";
      options = [ "nofail" ];
    };

    fileSystems."/mnt/t5" = {
      device = "/dev/disk/by-uuid/e3407ccb-a4f0-413a-bc00-a0b76797877e";
      fsType = "ext4";
      options = [ "nofail" ];
    };

    swapDevices = [ { device = "/swap.img"; } ];
  };
}

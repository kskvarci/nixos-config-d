# Enix filesystems: LVM root, EFI, data disks, and swap.
#
# d1/d2 are spinning disks for media storage; t5 is a portable USB SSD.
{ ... }:
{
  nixos.modules.storage-enix = { ... }: {
    fileSystems."/" = {
      device = "/dev/disk/by-id/dm-uuid-LVM-mbn8RBi7jebzdeGHYX9dBJpoGfH9LAZfc8dv2m8fAnyQhvxzYsBRjx383j3nbeM1";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/62a47e0d-7790-41fe-8edf-0a2bd5cb1e1d";
      fsType = "ext4";
    };

    fileSystems."/boot/efi" = {
      device = "/dev/disk/by-uuid/0C4E-6ECE";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

    fileSystems."/data/d1" = {
      device = "/dev/disk/by-uuid/831ac6a7-9cd8-40d1-bd62-39305a9617dc";
      fsType = "ext4";
    };

    fileSystems."/data/d2" = {
      device = "/dev/disk/by-uuid/58c6235e-83ce-4cb8-8481-44c3c2cdef55";
      fsType = "ext4";
    };

    fileSystems."/mnt/t5" = {
      device = "/dev/disk/by-uuid/e3407ccb-a4f0-413a-bc00-a0b76797877e";
      fsType = "ext4";
      options = [ "nofail" ];
    };

    swapDevices = [ { device = "/swap.img"; } ];
  };
}

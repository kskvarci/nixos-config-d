# Server CLI tools and shell environment for enix.
#
# Heavier package set than desktops — includes filesystem tools,
# network diagnostics, media processing, and system monitoring.
{ ... }:
{
  nixos.modules.server-shell = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      # Editors
      neovim

      # Core tools
      gh
      curl
      wget
      jq
      tree
      htop
      btop
      tmux
      screen

      # Filesystem & storage
      lvm2
      btrfs-progs
      xfsprogs
      parted
      gptfdisk
      e2fsprogs

      # Networking & diagnostics
      iproute2
      iptables
      nftables
      tcpdump
      ethtool
      bind

      # System
      pciutils
      usbutils
      lsof
      strace
      sysstat
      borgbackup

      # Media processing
      ffmpeg
    ];

    environment.variables.EDITOR = "nvim";
  };
}

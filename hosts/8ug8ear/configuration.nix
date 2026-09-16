{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/networking.nix
    ../../modules/nixos/users.nix
    ../../modules/nixos/display-manager.nix
    ../../modules/nixos/wm/hyprland.nix
    ../../modules/nixos/syncthing.nix
    ../../modules/nixos/ssh.nix
  ];

  # 8ug8ear is a ThinkPad X230 — legacy BIOS / MBR disk (/dev/sda1 is the
  # only partition; no ESP, no bios_grub). systemd-boot needs an ESP and
  # fails install with "efiSysMountPoint = '/boot' is not a mounted partition".
  # GRUB writes stage1 into the MBR gap and reads /boot/grub from the rootfs.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.configurationLimit = 100;

  system.stateVersion = "25.11";
}

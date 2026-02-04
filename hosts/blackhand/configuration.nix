{ config, pkgs, ... }:

{
  imports =
    [
      /etc/nixos/hardware-configuration.nix
      ../../modules/system/common.nix
      ../../modules/system/desktop-plasma.nix
      ../../modules/system/ssh.nix
      ../../modules/hardware/nvidia.nix
    ];

  networking.hostName = "blackhand";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "25.05";
}

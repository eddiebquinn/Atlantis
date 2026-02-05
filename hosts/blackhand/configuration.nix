{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/networking.nix
    ../../modules/nixos/users.nix
    ../../modules/nixos/display-manager.nix
    ../../modules/nixos/wm/hyprland.nix
    ../../modules/nixos/syncthing.nix
    ../../modules/nixos/audio.nix
    ../../modules/nixos/hardware/nvidia.nix
    ];

  networking.hostName = "blackhand";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "25.11";
}

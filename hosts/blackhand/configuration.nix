{ config, pkgs, lib, ... }:

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
    ../../modules/nixos/ssh.nix
    ../../modules/nixos/kube.nix
    ../../modules/nixos/gaming.nix
    ];

  networking.hostName = "blackhand";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  virtualisation.docker.enable = true;
  users.users.eddie.extraGroups = lib.mkAfter [ "docker" ];

  system.stateVersion = "25.11";
}


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

  # keep 8uh8ear-specific stuff here for now
  networking.hostName = "8uh8ear";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "25.11";
}

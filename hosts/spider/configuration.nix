{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/networking.nix
    ../../modules/nixos/users.nix
    ../../modules/nixos/wm/qtile.nix
  ];

  # keep spider-specific stuff here for now
  networking.hostName = "spider";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  system.stateVersion = "25.11";
}

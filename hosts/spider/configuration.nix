{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/base.nix
  ];

  # keep spider-specific stuff here for now
  networking.hostName = "spider";
  networking.networkmanager.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.xserver = {
    enable = true;
    autoRepeatDelay = 200;
    autoRepeatInterval = 35;
    windowManager.qtile.enable = true;
  };

  services.displayManager.ly.enable = true;
  services.libinput.enable = true;

  users.users.eddie = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  programs.firefox.enable = true;

  system.stateVersion = "25.11";
}

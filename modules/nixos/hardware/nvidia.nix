{ config, pkgs, lib, ... }:
{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false; # keep off unless you need it (laptops)
    open = false;                   # proprietary driver
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Usually not required explicitly, but harmless:
  boot.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];

  # If you hit flicker/tearing, consider:
  # services.xserver.displayManager.sessionCommands = ''
  #   ${pkgs.libglvnd}/bin/nvidia-settings --assign CurrentMetaMode="nvidia-auto-select +0+0 { ForceFullCompositionPipeline = On }"
  # '';
}

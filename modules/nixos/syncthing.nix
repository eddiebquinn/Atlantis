{ config, pkgs, ... }:

{
  services.syncthing = {
    enable = true;
    user = "eddie";
    dataDir = "/home/eddie/.local/share/syncthing";
    configDir = "/home/eddie/.config/syncthing";
    openDefaultPorts = true;
  };
}

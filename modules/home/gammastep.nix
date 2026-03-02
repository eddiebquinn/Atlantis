{ config, lib, pkgs, ... }:

{
  services.gammastep = {
    enable = true;

    # London (change if you want)
    latitude = 51.5072;
    longitude = -0.1276;

    temperature = {
      day = 5500;
      night = 3800;
    };
  };
}
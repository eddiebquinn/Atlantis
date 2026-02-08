{ config, pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.kubectl
  ];
}

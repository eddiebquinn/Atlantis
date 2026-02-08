{ config, pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.kubectl
    pkgs.k3sup
    pkgs.helm
  ];
}

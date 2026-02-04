{ config, pkgs, ... }:

{
  environment.systemPackages = [
    pkgs."fosrl-olm"
  ];
}

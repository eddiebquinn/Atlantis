{ config, lib, pkgs, ... }:

{
  users.users.eddie = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };
}
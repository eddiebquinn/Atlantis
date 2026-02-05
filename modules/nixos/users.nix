{ config, lib, pkgs, ... }:

{
  programs.zsh.enable = true;

  users.users.eddie = {
    isNormalUser = true;
    extraGroups = [ "wheel" /* etc */ ];
    shell = pkgs.zsh;
  };
}
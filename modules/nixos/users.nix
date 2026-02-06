{ config, lib, pkgs, ... }:

{
  programs.zsh.enable = true;

  users.users.eddie = {
    isNormalUser = true;
    extraGroups = [ "wheel" /* etc */ ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINt1KNkGPH+YPWl6qHX0PhbsevkEw8H1R86nOVV03k8Z (none)" # spider
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF+zfnhEIwiI2u03QnRjghuAYFQRbdzqT1pXHWD69eaG (none)" #blackhandO
    ];

  };
}
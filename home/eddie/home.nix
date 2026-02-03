{ config, pkgs, ... }:

{
  imports = [
    ../../modules/home/base.nix
    ../../modules/home/git.nix
    ../../modules/home/shell.nix
  ];
}

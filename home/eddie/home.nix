{ config, pkgs, ... }:

{
  imports = [
    ../../modules/home/base.nix
    ../../modules/home/git.nix
    ../../modules/home/shell.nix
  ];

  home.file.".config/hypr".source = ../../modules/home/configs/vendor/hypr;
  home.file.".config/waybar".source = ../../modules/home/configs/vendor/waybar;
}

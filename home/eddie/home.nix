{ config, pkgs, ... }:

{
  imports = [
    ../../modules/home/base.nix
    ../../modules/home/git.nix
    ../../modules/home/shell.nix
    ../../modules/home/alacritty.nix
    ../../modules/home/apps.nix
  ];

  home.file.".config/hypr".source = ../../modules/home/configs/hypr;
  home.file.".config/waybar".source = ../../modules/home/configs/waybar;
  home.file.".config/fastfetch".source = ../../modules/home/configs/fastfetch;
}

{ config, pkgs, ... }:

{
  imports = [
    ../../modules/home/base.nix
    ../../modules/home/git.nix
    ../../modules/home/shell.nix
    ../../modules/home/alacritty.nix
    ../../modules/home/apps.nix
  ];

  home.file.".config/hypr/hyprland.conf".source = ../../modules/home/configs/hypr/hyprland.conf;
  home.file.".config/hypr/hyprpaper.conf".source = ../../modules/home/configs/hypr/hyprpaper.conf;
  home.file.".config/hypr/wallpapers".source = ../../modules/home/configs/hypr/wallpapers;
  home.file.".config/waybar/style.css".source = ../../modules/home/configs/waybar/style.css;
  home.file.".config/fastfetch".source = ../../modules/home/configs/fastfetch;
  home.file.".config/wofi".source = ../../modules/home/configs/wofi;
}

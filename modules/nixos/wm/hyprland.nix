{ config, lib, pkgs, ... }:

{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  environment.systemPackages = with pkgs; [
    waybar
    hyprpaper
    wofi
    grim
    slurp
    wl-clipboard
  ];
}

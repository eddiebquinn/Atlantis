{ config, lib, pkgs, ... }:

{
  time.timeZone = "Europe/London";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    alacritty
    tree
    firefox
    codeium
    obsidian
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

}
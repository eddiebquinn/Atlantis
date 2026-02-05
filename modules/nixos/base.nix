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
    vscodium
    obsidian
    gnupg
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  programs.zsh.enable = true;
}

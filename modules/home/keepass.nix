{ config, pkgs, ... }:

{
  programs.keepassxc = {
    enable = true;
    settings = {
      Browser.Enabled = true;
      GUI = {
        ApplicationTheme = "dark";
      };
    };
  };

  home.packages = with pkgs; [
    syncthingtray
  ];
}

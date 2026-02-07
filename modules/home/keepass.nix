{ config, pkgs, ... }:

{
  programs.keepassxc = {
    enable = true;
    settings = {
      BrowserIntegration = {
        Enabled = true;
      };
    };
  };

  home.packages = with pkgs; [
    syncthingtray
  ];
}

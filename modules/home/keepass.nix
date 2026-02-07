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
  home.file.".config/mozilla/native-messaging-hosts/org.keepassxc.keepassxc_browser.json".source =
    "${pkgs.keepassxc}/lib/mozilla/native-messaging-hosts/org.keepassxc.keepassxc_browser.json";

  home.packages = with pkgs; [
    syncthingtray
  ];
}

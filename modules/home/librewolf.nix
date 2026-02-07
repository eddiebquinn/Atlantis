{ config, pkgs, inputs, ... }:

{
  programs.librewolf = {
    enable = true;
    profiles.eddie = {
      
      # Find these in about:config
      settings = {
        "dom.security.https_only_mode" = true;
        "browser.download.panel.shown" = true;
        "identity.fxaccounts.enabled" = false;
        "signon.rememberSignons" = false;
        "ui.systemUsesDarkTheme" = 1;
        "privacy.resistFingerprinting" = false;
      };

      search.engines = {
        "Nix Packages" = {
          urls = [{
            template = "https://search.nixos.org/packages";
            params = [
              { name = "type"; value = "packages"; }
              { name = "query"; value = "{searchTTerms}"; }
            ];
          }];
          icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
          definedAliases = [ "@np" ];
        };
      };
      search.force = true;

      # Get full list by running nix flake show "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons"
      extensions.packages = with inputs.firefox-addons.packages."x86_64-linux"; [
        ublock-origin
        keepassxc-browser
        clearurls
      ];
    };
  };
}
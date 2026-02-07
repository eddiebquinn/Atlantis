{ config, pkgs, inputs, ... }:

{
  programs.librewolf = {
    enable = true;
    profiles.eddie = {
      isDefault = true;
      
      # Find these in about:config
      settings = {
        "dom.security.https_only_mode" = true;
        "browser.download.panel.shown" = true;
        "identity.fxaccounts.enabled" = false;
        "signon.rememberSignons" = false;
        "ui.systemUsesDarkTheme" = 1;
        "layout.css.prefers-color-scheme.content-override" = 0;
        "privacy.resistFingerprinting" = false;
      };

      search = {
        force = true;

        default = "SearXNG";
        privateDefault = "SearXNG";

        # Only show these as search shortcuts / one-offs
        order = [ "SearXNG" "Nix Packages" ];

        engines = {
          "SearXNG" = {
            urls = [{
              template = "https://sx.eddiequinn.casa/search";
              params = [
                { name = "q"; value = "{searchTerms}"; }
              ];
            }];
            definedAliases = [ "@sx" ];
          };

          "Nix Packages" = {
            urls = [{
              template = "https://search.nixos.org/packages";
              params = [
                { name = "type"; value = "packages"; }
                { name = "query"; value = "{searchTerms}"; }
              ];
            }];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@np" ];
          };
        };
      };

      # Get full list by running nix flake show "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons"
      extensions.packages = with inputs.firefox-addons.packages."x86_64-linux"; [
        ublock-origin
        keepassxc-browser
        clearurls
      ];
    };
  };
}
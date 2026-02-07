{ config, pkgs, inputs, ... }:

{
  programs.librewolf = {
    enable = true;
    profiles.eddie = {
      isDefault = true;
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

        # Only show these as the one-off shortcut row
        order = [ "SearXNG" "Nix Packages" ];

        engines = {
          searxng = {
            name = "SearXNG";
            urls = [{
              template = "https://sx.eddiequinn.casa/search";
              params = [
                { name = "q"; value = "{searchTerms}"; }
              ];
            }];
            definedAliases = [ "@sx" ];
          };

          nix-packages = {
            name = "Nix Packages";
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

          # Hide builtin engines (HM treats entries with only metaData as builtin)
          bing.metaData.hidden = true;
          google.metaData.hidden = true;
          duckduckgo.metaData.hidden = true;
          startpage.metaData.hidden = true;
          metager.metaData.hidden = true;
          mojeek.metaData.hidden = true;
          duckduckgo-lite.metaData.hidden = true;
          searx-belgium.metaData.hidden = true;
          wikipedia.metaData.hidden = true;
        };
      };

      extensions.packages = with inputs.firefox-addons.packages.${pkgs.system}; [
        ublock-origin
        keepassxc-browser
        clearurls
      ];
      
    };
  };
}

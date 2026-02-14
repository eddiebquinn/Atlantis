{ config, pkgs, inputs, ... }:

{
  programs.librewolf = {
    enable = true;

    profiles.eddie = {
      id = 0;
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

    profiles.chats = {
      id = 1;
      isDefault = false;

      settings = {
        "ui.systemUsesDarkTheme" = 1;
        "layout.css.prefers-color-scheme.content-override" = 0;

        "privacy.sanitize.sanitizeOnShutdown" = false;
        "privacy.clearOnShutdown.cookies" = false;
        "privacy.clearOnShutdown.offlineApps" = false;
        "privacy.clearOnShutdown.siteSettings" = false;
        "privacy.clearOnShutdown.cache" = false;
        "privacy.clearOnShutdown.history" = false;
        "privacy.clearOnShutdown.downloads" = false;
        "privacy.clearOnShutdown.formdata" = false;
        "privacy.clearOnShutdown.sessions" = false;

        "browser.startup.page" = 3;
        "browser.sessionstore.resume_from_crash" = true;

        "privacy.resistFingerprinting" = false;
        "signon.rememberSignons" = true;
      };

      extensions.packages = with inputs.firefox-addons.packages."x86_64-linux"; [
        ublock-origin
        keepassxc-browser
        clearurls
      ];
    };
  };

  home.file.".local/share/applications/librewolf-chats.desktop".text = ''
    [Desktop Entry]
    Name=LibreWolf (Chats)
    Exec=librewolf --no-remote -P chats
    Icon=librewolf
    Type=Application
    Categories=Network;Chat;
    StartupWMClass=LibreWolf
  '';
}
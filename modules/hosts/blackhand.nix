{ config, ... }:

{
  flake.modules.nixos.blackhand =
    { lib, ... }:
    {
      imports = [
        config.flake.modules.nixos.workstation
        config.flake.modules.nixos.audio
        config.flake.modules.nixos.nvidia
        config.flake.modules.nixos.kube
        config.flake.modules.nixos.gaming
        config.flake.modules.nixos.internet-waybar
      ];

      networking.hostName = "blackhand";

      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      virtualisation.docker.enable = true;
      users.users.eddie.extraGroups = lib.mkAfter [ "docker" ];

      system.stateVersion = "25.11";

      # Host-specific home config. Merges with the `users.eddie`
      # definition in modules/flake/home-manager.nix.
      home-manager.users.eddie = {
        home.file.".config/waybar/config.jsonc".source = ./blackhand/waybar.jsonc;

        services.gpg-agent.sshKeys = [
          "A9DB04F9B83610084AADB572724309E505A4D4B0"
        ];

        # Triple-head desk. These three attributes used to live in
        # modules/home/hyprland.nix as hostname-keyed lookup tables;
        # under the dendritic pattern the host that has the monitors
        # is the file that describes them.
        atlantis.hyprland.monitors = [
          {
            output = "DP-3";
            mode = "1920x1080@60";
            position = "-1080x0";
            scale = "1";
            transform = 1;
          }
          {
            output = "DP-2";
            mode = "3840x2160@60";
            position = "0x0";
            scale = "1.5";
          }
          {
            output = "DP-1";
            mode = "1920x1080@60";
            position = "2560x0";
            scale = "1";
            transform = 3;
          }
        ];

        atlantis.hyprland.workspaceBinds = [
          # Bank 1: SUPER+CTRL+1..9 → workspaces 1..9 (DP-3, left)
          { key = "CTRL + 1"; workspace = 1; }
          { key = "CTRL + 2"; workspace = 2; }
          { key = "CTRL + 3"; workspace = 3; }
          { key = "CTRL + 4"; workspace = 4; }
          { key = "CTRL + 5"; workspace = 5; }
          { key = "CTRL + 6"; workspace = 6; }
          { key = "CTRL + 7"; workspace = 7; }
          { key = "CTRL + 8"; workspace = 8; }
          { key = "CTRL + 9"; workspace = 9; }

          # Bank 2: SUPER+1..9 → workspaces 11..19 (DP-2, centre)
          { key = "1"; workspace = 11; }
          { key = "2"; workspace = 12; }
          { key = "3"; workspace = 13; }
          { key = "4"; workspace = 14; }
          { key = "5"; workspace = 15; }
          { key = "6"; workspace = 16; }
          { key = "7"; workspace = 17; }
          { key = "8"; workspace = 18; }
          { key = "9"; workspace = 19; }

          # Bank 3: SUPER+ALT+1..9 → workspaces 21..29 (DP-1, right)
          { key = "ALT + 1"; workspace = 21; }
          { key = "ALT + 2"; workspace = 22; }
          { key = "ALT + 3"; workspace = 23; }
          { key = "ALT + 4"; workspace = 24; }
          { key = "ALT + 5"; workspace = 25; }
          { key = "ALT + 6"; workspace = 26; }
          { key = "ALT + 7"; workspace = 27; }
          { key = "ALT + 8"; workspace = 28; }
          { key = "ALT + 9"; workspace = 29; }
        ];

        atlantis.hyprland.workspaceRules = [
          # Bank 1: workspaces 1-9 → DP-3 (left)
          { workspace = 1;  monitor = "DP-3"; default = true; }
          { workspace = 2;  monitor = "DP-3"; default = false; }
          { workspace = 3;  monitor = "DP-3"; default = false; }
          { workspace = 4;  monitor = "DP-3"; default = false; }
          { workspace = 5;  monitor = "DP-3"; default = false; }
          { workspace = 6;  monitor = "DP-3"; default = false; }
          { workspace = 7;  monitor = "DP-3"; default = false; }
          { workspace = 8;  monitor = "DP-3"; default = false; }
          { workspace = 9;  monitor = "DP-3"; default = false; }

          # Bank 2: workspaces 11-19 → DP-2 (centre)
          { workspace = 11; monitor = "DP-2"; default = true; }
          { workspace = 12; monitor = "DP-2"; default = false; }
          { workspace = 13; monitor = "DP-2"; default = false; }
          { workspace = 14; monitor = "DP-2"; default = false; }
          { workspace = 15; monitor = "DP-2"; default = false; }
          { workspace = 16; monitor = "DP-2"; default = false; }
          { workspace = 17; monitor = "DP-2"; default = false; }
          { workspace = 18; monitor = "DP-2"; default = false; }
          { workspace = 19; monitor = "DP-2"; default = false; }

          # Bank 3: workspaces 21-29 → DP-1 (right)
          { workspace = 21; monitor = "DP-1"; default = true; }
          { workspace = 22; monitor = "DP-1"; default = false; }
          { workspace = 23; monitor = "DP-1"; default = false; }
          { workspace = 24; monitor = "DP-1"; default = false; }
          { workspace = 25; monitor = "DP-1"; default = false; }
          { workspace = 26; monitor = "DP-1"; default = false; }
          { workspace = 27; monitor = "DP-1"; default = false; }
          { workspace = 28; monitor = "DP-1"; default = false; }
          { workspace = 29; monitor = "DP-1"; default = false; }
        ];
      };
    };
}

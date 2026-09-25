{ config, ... }:

{
  flake.modules.nixos.spider = {
    imports = [ config.flake.modules.nixos.workstation config.flake.modules.nixos.internet-waybar ];

    # keep spider-specific stuff here for now
    networking.hostName = "spider";

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    system.stateVersion = "25.11";

    # Host-specific home config. Merges with the `users.eddie`
    # definition in modules/flake/home-manager.nix.
    home-manager.users.eddie = {
      home.file.".config/waybar/config.jsonc".source = ./spider/waybar.jsonc;

      services.gpg-agent.sshKeys = [
        "6C456670D420AA1C989355232D469E70938B45F0"
      ];

      # Single display: no monitor declarations, no workspace-to-monitor
      # routing, flat SUPER+1..9 workspaces.
      atlantis.hyprland.workspaceBinds = [
        { key = "1"; workspace = 1; }
        { key = "2"; workspace = 2; }
        { key = "3"; workspace = 3; }
        { key = "4"; workspace = 4; }
        { key = "5"; workspace = 5; }
        { key = "6"; workspace = 6; }
        { key = "7"; workspace = 7; }
        { key = "8"; workspace = 8; }
        { key = "9"; workspace = 9; }
      ];
    };
  };
}

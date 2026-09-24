{ config, ... }:

{
  flake.modules.nixos."8ug8ear" = {
    imports = [
      config.flake.modules.nixos.workstation
      config.flake.modules.nixos.pangolin-cli
    ];

    networking.hostName = "8ug8ear";

    # 8ug8ear is a ThinkPad X230 — legacy BIOS / MBR disk (/dev/sda1 is the
    # only partition; no ESP, no bios_grub). systemd-boot needs an ESP and
    # fails install with "efiSysMountPoint = '/boot' is not a mounted partition".
    # GRUB writes stage1 into the MBR gap and reads /boot/grub from the rootfs.
    boot.loader.grub.enable = true;
    boot.loader.grub.device = "/dev/sda";
    boot.loader.grub.configurationLimit = 100;

    system.stateVersion = "25.11";

    # Host-specific home config. Merges with the `users.eddie`
    # definition in modules/flake/home-manager.nix.
    home-manager.users.eddie = {
      home.file.".config/waybar/config.jsonc".source = ./8ug8ear/waybar.jsonc;

      services.gpg-agent.sshKeys = [
        "6C456670D420AA1C989355232D469E70938B45F0"
      ];

      # Single internal display: no monitor declarations, no
      # workspace-to-monitor routing, flat SUPER+1..9 workspaces.
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

{ config, lib, pkgs, ... }:

{
  imports = [
    ../../modules/home/base.nix
    ../../modules/home/git.nix
    ../../modules/home/shell.nix
    ../../modules/home/alacritty.nix
    ../../modules/home/keepass.nix
    ../../modules/home/gpg.nix
    ../../modules/home/librewolf.nix
    ../../modules/home/devlopment.nix
    ../../modules/home/gammastep.nix
    ../../modules/home/signal.nix

    # Hyprland compositor session — HM layer.
    ../../modules/home/hyprland.nix
  ];

  # hyprpaper.conf stays — HM owns it via home.file.
  home.file.".config/hypr/hyprpaper.conf".source = ../../modules/home/configs/hypr/hyprpaper.conf;
  home.file.".config/hypr/wallpapers".source = ../../modules/home/configs/hypr/wallpapers;
  home.file.".config/waybar/style.css".source = ../../modules/home/configs/waybar/style.css;
  home.file.".config/fastfetch".source = ../../modules/home/configs/fastfetch;
  home.file.".config/wofi".source = ../../modules/home/configs/wofi;

  # §2.9 — auto-restart hyprpaper on conf change.
  home.activation.hyprpaperRestart =
    lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      if pgrep -x hyprpaper >/dev/null 2>&1; then
        echo "[atlantis] restarting hyprpaper (conf changed)"
        pkill -x hyprpaper 2>/dev/null || true
        sleep 0.5
        setsid nohup hyprpaper </dev/null >/dev/null 2>&1 &
      fi
    '';
}


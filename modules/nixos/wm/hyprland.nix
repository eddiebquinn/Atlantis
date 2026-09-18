{ config, lib, pkgs, ... }:

# Hyprland compositor — NixOS layer.
#
# Owns ONLY compositor installation + session registration:
#
#   * programs.hyprland (compositor package + xwayland)
#   * environment.pathsToLink (xdg-desktop-portal applications,
#     required by home-manager 26.05 under useUserPackages = true)
#
# Session configuration, binds, env, autostart, and session support
# programs (waybar, hyprpaper, wofi, grim, slurp, wl-clipboard) live
# on the home-manager layer in modules/home/hyprland.nix.
#
# The wayland-session.desktop entry has to be in /run/current-system
# for the display manager to resolve it before any user session is
# spawned — so compositor enablement MUST stay on the NixOS layer.

{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # xdg-desktop-portal needs /share/applications and
  # /share/xdg-desktop-portal reachable from the user session PATH
  # to satisfy the HM 26.05 useUserPackages assertion. See
  # openspec/changes/atlantis-26-05-declarative-compositor
  # scenario "Portal assertion passes at eval time".
  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
  ];

  xdg.portal.enable = true;
}

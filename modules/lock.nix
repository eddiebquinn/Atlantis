{
  # Session locking — the whole feature, both layers, one file.
  #
  # Same shape as modules/hyprland.nix: a concern spanning the NixOS
  # and home-manager boundaries lives in one place.
  #
  # Responsibility split (issue #3):
  #   * System (NixOS): hyprlock PAM service + system package via
  #     programs.hyprlock. Sleep *policy* stays with logind and is
  #     host-specific (laptop suspends on lid close) — see
  #     modules/hosts/8ug8ear.nix.
  #   * User session (home-manager): lock UI config (hyprlock.conf) +
  #     idle detection (hypridle). Locking is a session concern; ly
  #     handles pre-login only, never session locking.
  #
  # Lock stack ships to every host (software repo-wide feature): manual
  # SUPER+l locking and idle locking are useful everywhere. Suspend
  # behaviour is only meaningful on the laptop.

  flake.modules.nixos.workstation = {
    # Installs hyprlock system-wide and, critically, registers the
    # PAM service (/etc/pam.d/hyprlock). Without the PAM entry
    # hyprlock cannot authenticate the password.
    programs.hyprlock.enable = true;
  };

  flake.modules.homeManager.eddie =
    { config, lib, pkgs, ... }:
    let
      # Lock UI style. "tui" (default) is a minimal terminal-style
      # screen — pure black, monospace prompt line at the bottom,
      # no wallpaper / clock / date. "themed" is the fuller lock
      # screen with wallpaper + clock + date, used when the user
      # wants the lock screen to feel like the session itself.
      lockConf =
        if config.atlantis.lock.style == "themed" then
          ./hyprland/hyprlock-themed.conf
        else
          ./hyprland/hyprlock-tui.conf;
    in
    {
      options.atlantis.lock = {
        style = lib.mkOption {
          type = lib.types.enum [ "tui" "themed" ];
          default = "tui";
          description = ''
            Lock screen appearance. "tui" is a minimal terminal-style
            screen (pure black, monospace prompt at the bottom,
            no wallpaper / clock / date) — mirrors ly. "themed"
            renders the session wallpaper, clock, and date.
          '';
        };
      };

      config = {
        # Idle → lock, and lock-on-suspend. HM generates the systemd
        # user service (WantedBy graphical-session.target, active on
        # every host because wayland.windowManager.hyprland.systemd
        # is enabled in modules/hyprland.nix).
        services.hypridle = {
          enable = true;

          settings = {
            general = {
              lock_cmd = "pidof hyprlock || hyprlock";
              # Lock BEFORE suspend so resume lands on the lock screen,
              # not a black screen (the original issue #3 symptom).
              before_sleep_cmd = "pidof hyprlock || hyprlock";
              # Re-light displays after resume in case DPMS-off was in
              # effect when the machine slept.
              after_sleep_cmd = "hyprctl dispatch dpms on";
              ignore_dbus_inhibit = false;
            };

            listener = [
              {
                # 10 min idle → lock (issue #3 target).
                timeout = 600;
                on-timeout = "pidof hyprlock || hyprlock";
              }
              {
                # 10.5 min idle → displays off. Lock UI stays up; any
                # input wakes the display straight into the lock screen.
                timeout = 630;
                on-timeout = "hyprctl dispatch dpms off";
                on-resume = "hyprctl dispatch dpms on";
              }
            ];
          };
        };

        # hyprlock UI. Config written as a sibling conf file via
        # xdg.configFile.source — same pattern as hyprpaper.conf in
        # modules/hyprland.nix. The chosen file is `lockConf`, picked
        # by `atlantis.lock.style`. Using HM's programs.hyprlock would
        # duplicate the package in the user profile; the package and
        # PAM wiring come from the NixOS layer above.
        xdg.configFile."hypr/hyprlock.conf".source = lockConf;
      };
    };
}

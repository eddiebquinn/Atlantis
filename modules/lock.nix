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
    {
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

      # hyprlock UI. Config written directly (same pattern as
      # hyprpaper.conf in modules/hyprland.nix) because the package
      # and PAM wiring come from the NixOS layer above — using HM's
      # programs.hyprlock would duplicate the package in the user
      # profile.
      xdg.configFile."hypr/hyprlock.conf".text = ''
        # Session lock screen. Tokyo-Night palette to match the session.

        background {
            monitor =
            path = ${./hyprland/wallpapers/black-triangle.png}
            color = rgba(26, 27, 38, 1.0)
            blur_passes = 2
            blur_size = 4
            brightness = 0.55
        }

        # Clock.
        label {
            monitor =
            text = cmd[update:60000:] date +'%H:%M'
            color = rgba(187, 154, 247, 0.95)
            font_size = 90
            position = 0, 160
            halign = center
            valign = center
        }

        # Date.
        label {
            monitor =
            text = cmd[update:3600000:] date +'%A, %d %B %Y'
            color = rgba(169, 177, 214, 0.85)
            font_size = 24
            position = 0, 60
            halign = center
            valign = center
        }

        # Password entry.
        input-field {
            monitor =
            size = 240, 48
            outline_thickness = 2
            dots_size = 0.25
            dots_spacing = 0.3
            dots_center = true
            outer_color = rgba(187, 154, 247, 0.6)
            inner_color = rgba(26, 27, 38, 0.8)
            font_color = rgba(169, 177, 214, 1.0)
            fade_on_empty = false
            placeholder_text =
            position = 0, -80
            halign = center
            valign = center
        }
      '';
    };
}

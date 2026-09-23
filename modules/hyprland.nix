{
  # Hyprland — the whole feature, both layers, one file.
  #
  # This is the shape the dendritic pattern is for: a concern that
  # spans the NixOS and home-manager boundaries lives in one place,
  # instead of being split across modules/nixos/wm/ and modules/home/
  # the way the pre-conversion tree had it.

  # ── NixOS layer ────────────────────────────────────────────────
  #
  # Owns ONLY compositor installation + session registration:
  #
  #   * programs.hyprland (compositor package + xwayland)
  #   * environment.pathsToLink (xdg-desktop-portal applications,
  #     required by home-manager 26.05 under useUserPackages = true)
  #
  # The wayland-session.desktop entry has to be in /run/current-system
  # for the display manager to resolve it before any user session is
  # spawned — so compositor enablement MUST stay on the NixOS layer.
  flake.modules.nixos.workstation = {
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    # xdg-desktop-portal needs /share/applications and
    # /share/xdg-desktop-portal reachable from the user session PATH
    # to satisfy the HM 26.05 useUserPackages assertion. See
    # openspec/changes/archive/2026-09-18-atlantis-26-05-declarative-compositor
    # scenario "Portal assertion passes at eval time".
    environment.pathsToLink = [
      "/share/applications"
      "/share/xdg-desktop-portal"
    ];

    xdg.portal.enable = true;
  };

  # ── home-manager layer ─────────────────────────────────────────
  #
  # Session config, binds, env, autostart, and the session support
  # programs. Per-host monitor / workspace data is NOT in this file —
  # hosts set `atlantis.hyprland.*` in modules/hosts/<name>.nix. That
  # replaces the old `hostName` specialArg and the three
  # hostname-keyed lookup tables this module used to carry.
  flake.modules.homeManager.eddie =
    { config, lib, pkgs, ... }:
    let
      cfg = config.atlantis.hyprland;

      # NOTE ON INDENTATION, here and in extraConfig below: these
      # `''` blocks are reproduced at their original columns rather
      # than re-indented to match the surrounding code. The blocks
      # contain column-0 interpolations, which participate in Nix's
      # minimum-indentation stripping — moving them changes the
      # generated Lua. Left verbatim, the output is byte-identical to
      # the pre-conversion tree.

      # Render this host's monitor list into Lua hl.monitor() calls.
      monitorLua = lib.concatMapStringsSep "\n" (m: ''
    hl.monitor({
        output    = ${builtins.toJSON m.output},
        mode      = ${builtins.toJSON m.mode},
        position  = ${builtins.toJSON m.position},
        scale     = ${builtins.toJSON m.scale},
${lib.optionalString (m.transform != null) ("        transform = " + toString m.transform + ",")}    })''
      ) cfg.monitors;

      # Render the bind tables into Lua. Each entry becomes one bind.
      workspaceBindLua = lib.concatMapStringsSep "\n" (
        b: "    hl.bind(mainMod .. \" + ${b.key}\", hl.dsp.focus({ workspace = ${toString b.workspace} }))"
      ) cfg.workspaceBinds;

      workspaceMoveBindLua = lib.concatMapStringsSep "\n" (
        b:
        "    hl.bind(mainMod .. \" + SHIFT + ${b.key}\", hl.dsp.window.move({ workspace = ${toString b.workspace} }))"
      ) cfg.workspaceBinds;

      # Render workspace_rule entries (default-per-monitor routing).
      workspaceRuleLua = lib.concatMapStringsSep "\n" (r: ''
    hl.workspace_rule({
        workspace = ${toString r.workspace},
        monitor   = ${builtins.toJSON r.monitor},
        default   = ${builtins.toJSON r.default},
    })''
      ) cfg.workspaceRules;
    in
    {
      options.atlantis.hyprland = {
        monitors = lib.mkOption {
          type = lib.types.listOf (
            lib.types.submodule {
              options = {
                output = lib.mkOption { type = lib.types.str; };
                mode = lib.mkOption { type = lib.types.str; };
                position = lib.mkOption { type = lib.types.str; };
                scale = lib.mkOption { type = lib.types.str; };
                transform = lib.mkOption {
                  type = lib.types.nullOr lib.types.int;
                  default = null;
                };
              };
            }
          );
          default = [ ];
          description = "Monitor layout for this host, rendered into hl.monitor() calls.";
        };

        workspaceBinds = lib.mkOption {
          type = lib.types.listOf (
            lib.types.submodule {
              options = {
                key = lib.mkOption { type = lib.types.str; };
                workspace = lib.mkOption { type = lib.types.int; };
              };
            }
          );
          default = [ ];
          description = ''
            Workspace switch binds for this host. Each entry also produces the
            matching SUPER + SHIFT move bind.
          '';
        };

        workspaceRules = lib.mkOption {
          type = lib.types.listOf (
            lib.types.submodule {
              options = {
                workspace = lib.mkOption { type = lib.types.int; };
                monitor = lib.mkOption { type = lib.types.str; };
                default = lib.mkOption {
                  type = lib.types.bool;
                  default = false;
                };
              };
            }
          );
          default = [ ];
          description = "Workspace-to-monitor default routing for this host.";
        };
      };

      config = {
        # Session support programs the Hyprland session binds to or
        # autostarts.
        home.packages = [
          pkgs.waybar
          pkgs.hyprpaper
          pkgs.wofi
          pkgs.grim
          pkgs.slurp
          pkgs.wl-clipboard
        ];

        # hyprpaper has no home-manager program module, so this feature
        # owns its config and wallpapers directly, beside the module.
        home.file.".config/hypr/hyprpaper.conf".source = ./hyprland/hyprpaper.conf;
        home.file.".config/hypr/wallpapers".source = ./hyprland/wallpapers;

        # Stub-removal activation hook: clears prior-MR-!36 leftovers
        home.activation.removeLegacyHyprlandLeftovers =
          lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            run() {
              path="$1"
              if [ -e "$path" ]; then
                $DRY_RUN_CMD rm -f "$path"
              fi
            }

            # MR !36 leftovers on 8ug8ear — listed in the proposal
            run "$HOME/.config/hypr/hyprland.conf.bak"
            run "$HOME/.config/hypr/hyprland.lua.bak"
          '';

        # §2.9 — auto-restart hyprpaper on conf change.
        home.activation.hyprpaperRestart = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
          if pgrep -x hyprpaper >/dev/null 2>&1; then
            echo "[atlantis] restarting hyprpaper (conf changed)"
            pkill -x hyprpaper 2>/dev/null || true
            sleep 0.5
            setsid nohup hyprpaper </dev/null >/dev/null 2>&1 &
          fi
        '';

        wayland.windowManager.hyprland = {
          enable = true;

          # Lua is mandatory on Hyprland 0.55+ (the key=value hyprlang
          configType = "lua";

          # Defer compositor installation to the NixOS layer
          package = null;
          portalPackage = null;

          # Keep the user systemd sessiond active so waybar / hyprpaper
          systemd.enable = true;
        };

        # Raw Lua config content. This is the ONLY place binds, env vars,
        wayland.windowManager.hyprland.extraConfig = ''
    -- Hyprland session config (HM-generated, lua form).
    local mainMod  = "SUPER"
    local terminal      = "alacritty"
    local fileManager   = "dolphin"
    local menu          = "wofi --show drun"
    local reload_waybar = "pkill waybar; waybar &"
    local snip          = "grim -g $(slurp) - | wl-copy"

    -- §2.3 — environment variables.
    hl.env("GTK_THEME", "Tokyo-Night-Dark")
    hl.env("GTK_ICON_THEME", "Adwaita")
    hl.env("XCURSOR_SIZE", "24")
    hl.env("HYPRCURSOR_SIZE", "24")
    hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
    hl.env("XDG_SESSION_TYPE", "wayland")

    -- §3.1 — per-host monitor declarations.
    ${monitorLua}

    -- §2.4 first commit — Terminal. Replaces the legacy conf's
    hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))

    -- §2.1 — general section (gaps, borders, layout).
    hl.config({
        general = {
            gaps_in         = 6,
            gaps_out        = 8,
            border_size     = 2,
            layout          = "dwindle",
            resize_on_border = false,
            allow_tearing   = false,
            col = {
                active_border   = { colors = { "rgba(ffffffff)", "rgba(ffffffff)" }, angle = 45 },
                inactive_border = "rgba(595959aa)",
            },
        },
    })

    -- §2.2a — decoration section (round corners, opacity, blur).
    hl.config({
        decoration = {
            rounding        = 6,
            rounding_power  = 2,
            active_opacity  = 1.0,
            inactive_opacity = 1.0,
            blur = {
                enabled  = true,
                size     = 3,
                passes   = 1,
                vibrancy = 0.1696,
            },
        },
    })

    -- §2.2b — disable the Hyprland session-start splash.
    hl.config({
        misc = {
            disable_splash_rendering = true,
        },
    })

    -- §2.4a — core utility binds (Q kill, M logout, E file
    hl.bind(mainMod .. " + Q", hl.dsp.window.kill())
    hl.bind(mainMod .. " + M", hl.dsp.exit())
    hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
    hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
    hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(menu))
    hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(reload_waybar))
    hl.bind(mainMod .. " + S", function ()
        os.execute(snip)
    end)

    -- §2.4b — per-host workspace switches.
${workspaceBindLua}

    -- §2.5b — per-host workspace moves (SUPER + SHIFT + <key>).
${workspaceMoveBindLua}

    -- §3.3 — per-host workspace-to-monitor default routing.
${workspaceRuleLua}

    -- §2.8a — autostart hyprpaper so the wallpaper renders on
    hl.curve("default",  { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })
    hl.curve("myBezier", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })

    hl.config({
        animations = {
            enabled = true,
        },
    })

    hl.animation({ leaf = "windows",     enabled = true, speed = 7, bezier = "myBezier" })
    hl.animation({ leaf = "windowsOut",  enabled = true, speed = 7, bezier = "default",  style = "popin 80%" })
    hl.animation({ leaf = "border",      enabled = true, speed = 10, bezier = "default" })
    hl.animation({ leaf = "borderangle", enabled = true, speed = 8,  bezier = "default" })
    hl.animation({ leaf = "fade",        enabled = true, speed = 7,  bezier = "default" })
    hl.animation({ leaf = "workspaces",  enabled = true, speed = 6,  bezier = "default" })

    -- §2.2f — dwindle + master layout config.
    hl.config({
        dwindle = {
            preserve_split = true,
        },
        master = {
            new_status = "master",
        },
    })

    -- §2.2g — cursor section.
    hl.config({
        cursor = {
            inactive_timeout     = 20,
            no_hardware_cursors  = 1,
        },
    })

    -- §2.2h — input section (kb layout, follow_mouse, sensitivity,
    hl.config({
        input = {
            kb_layout     = "gb",
            follow_mouse  = 1,
            sensitivity   = 0,
            repeat_rate   = 35,
            repeat_delay  = 200,
            touchpad = {
                natural_scroll = false,
            },
        },
    })

    -- §2.7 — windowrule: suppress-maximize.
    local suppress_maximize = hl.window_rule({
        name  = "suppress-maximize-all",
        match = { class = ".*" },
        suppress_event = "maximize",
    })

    -- §2.5 — focus / scroll / mouse binds.
    hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left"  }))
    hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
    hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up"    }))
    hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down"  }))

    hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
    hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

    hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
    hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

    hl.on("hyprland.start", function ()
        os.execute("hyprpaper &")
        os.execute("waybar &")
    end)
  '';
      };
    };
}

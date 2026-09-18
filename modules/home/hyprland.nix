{ config, lib, pkgs, hostName, ... }:

# Hyprland compositor session — home-manager layer.
let

allHostsMonitors = {
  "8ug8ear" = [];
  "spider"  = [];
  "blackhand" = [
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
};

# Render the per-host monitor list into Lua hl.monitor() calls.
perHostMonitorLua = lib.concatMapStringsSep "\n" (m: ''
    hl.monitor({
        output    = ${builtins.toJSON m.output},
        mode      = ${builtins.toJSON m.mode},
        position  = ${builtins.toJSON m.position},
        scale     = ${builtins.toJSON m.scale},
${lib.optionalString (m ? transform) ("        transform = " + toString m.transform + ",")}    })''
) allHostsMonitors.${hostName} or [];

allHostsWorkspaceBinds = {
  "8ug8ear" = [
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
  "spider" = [
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
  # Blackhand: triple-head workspace banks, ported from the
  "blackhand" = [
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
};

# Select this host's bind table. Falls back to [] for unknown
perHostWorkspaceBinds = allHostsWorkspaceBinds.${hostName} or [];
perHostWorkspaceMoveBinds = perHostWorkspaceBinds;

# Per-host workspace-rule tables (default-per-monitor routing).
allHostsWorkspaceRules = {
  "8ug8ear" = [];
  "spider"  = [];
  "blackhand" = [
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

perHostWorkspaceRules = allHostsWorkspaceRules.${hostName} or [];

# Render the per-host bind tables into Lua. Each entry becomes one
perHostWorkspaceBindLua = lib.concatMapStringsSep "\n" (b:
  "    hl.bind(mainMod .. \" + ${b.key}\", hl.dsp.focus({ workspace = ${toString b.workspace} }))"
) perHostWorkspaceBinds;
perHostWorkspaceMoveBindLua = lib.concatMapStringsSep "\n" (b:
  "    hl.bind(mainMod .. \" + SHIFT + ${b.key}\", hl.dsp.window.move({ workspace = ${toString b.workspace} }))"
) perHostWorkspaceMoveBinds;

# Render per-host workspace_rule entries. Each becomes one
perHostWorkspaceRuleLua = lib.concatMapStringsSep "\n" (r: ''
    hl.workspace_rule({
        workspace = ${toString r.workspace},
        monitor   = ${builtins.toJSON r.monitor},
        default   = ${builtins.toJSON r.default},
    })''
) perHostWorkspaceRules;

in

{
  # Session support programs the Hyprland session binds to or
  home.packages = [
    pkgs.waybar
    pkgs.hyprpaper
    pkgs.wofi
    pkgs.grim
    pkgs.slurp
    pkgs.wl-clipboard
  ];

  # Stub-removal activation hook: clears prior-MR-!36 leftovers
  home.activation.removeLegacyHyprlandLeftovers = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
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
    ${perHostMonitorLua}

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
${perHostWorkspaceBindLua}

    -- §2.5b — per-host workspace moves (SUPER + SHIFT + <key>).
${perHostWorkspaceMoveBindLua}

    -- §3.3 — per-host workspace-to-monitor default routing.
${perHostWorkspaceRuleLua}

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
}

{
  # Pangolin ZTNA client (fosrl/cli) — the single-binary WireGuard-based
  # zero-trust-network-access client for end-user devices. Distinct from
  # Newt (fosrl/newt), which is a docker-compose tunnel connector for
  # homelab hosts, deployed via cf-pangolin + Ansible.
  #
  # Opt-in: imported by 8ug8ear only. Other hosts import this aggregate
  # when they need ZTNA access to Pangolin core.
  #
  # Module shape (revised after a real-world exec failure):
  #   - NixOS aggregate  : the binary `pangolin-cli` AND a
  #                        `pangolin-waybar-status` system package that
  #                        the waybar fragment invokes by absolute path.
  #   - Home Manager    : the waybar include fragment that bakes the
  #                        absolute exec path in at Nix-eval time.
  #
  # Why this shape (after Exit-127 debugging on 8ug8ear):
  #   Waybar's `exec` calls g_spawn, which inherits a minimal env (no
  #   login-shell `~/.local/bin` on PATH; no `~` expansion). A literal
  #   `~/.local/bin/pangolin-waybar-status` exec value silently fails
  #   the waybar module stays registered but renders blank. The fix is
  #   to put the script on a path that exists at the absolute name
  #   waybar inherits: `/run/current-system/sw/bin/...`. Both NixOS
  #   and the waybar fragment compute that path at build time so it
  #   stays correct across hosts and rebuilds.

  flake.modules.nixos.pangolin-cli =
    { config, lib, pkgs, ... }:
    let
      # A system-installed wrapper so waybar's g_spawn resolves the exec
      # path without `~` expansion or PATH lookup. Lives at
      # /run/current-system/sw/bin/pangolin-waybar-status in the active
      # system profile.
      helper = pkgs.writeShellScriptBin "pangolin-waybar-status" ''
        set -euo pipefail

        emit() {
          local cls="$1" tip="$2" txt="$3"
          printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$txt" "$tip" "$cls"
        }

        # 1. Interface up? Cheapest signal — no fork, no jq.
        if ip -br addr show pangolin 2>/dev/null | grep -q .; then
          emit connected 'Pangolin tunnel interface is up' '● pangolin'
          exit 0
        fi

        # 2. CLI status (only runs if `pangolin` and `jq` exist).
        if command -v pangolin >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
          if pangolin status --json 2>/dev/null \
             | jq -e '.connected and .registered' >/dev/null 2>&1; then
            org=$(pangolin status --json 2>/dev/null \
                  | jq -r '.orgId // "?"' 2>/dev/null || echo '?')
            emit connected "Pangolin connected (org: ${org})" '● pangolin'
            exit 0
          fi
        fi

        # 3. Fallback.
        emit disconnected 'Pangolin not connected' '● pangolin'
        exit 0
      '';
    in
    {
      environment.systemPackages = [
        pkgs.pangolin-cli
        helper
      ];
    };

  # Home Manager: waybar include fragment. The exec value is the
  # absolute path Nix exposes in the system profile for
  # `pkgs.writeShellScriptBin` outputs — `/run/current-system/sw/bin/<name>`
  # is always resolvable across rebuilds (it's a stable Nix profile
  # symlink, not a store path that rotates on every derivation update
  # the way `~`-relative paths or `$PATH` would). waybar's g_spawn
  # sees it as a literal path — no `~` expansion, no PATH lookup — so
  # the module actually executes.
  flake.modules.homeManager.eddie =
    { ... }:
    {
      xdg.configFile."waybar/includes/pangolin.jsonc".text = ''
        {
            "custom/pangolin": {
                "exec": "/run/current-system/sw/bin/pangolin-waybar-status",
                "interval": 10,
                "return-type": "json",
                "format": "{text}",
                "tooltip": true,
                "on-click": "pangolin status"
            }
        }
      '';
    };
}

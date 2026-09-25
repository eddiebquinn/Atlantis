{
  # Pangolin ZTNA client (fosrl/cli) — the single-binary WireGuard-based
  # zero-trust-network-access client for end-user devices. Distinct from
  # Newt (fosrl/newt), which is a docker-compose tunnel connector for
  # homelab hosts, deployed via cf-pangolin + Ansible.
  #
  # Opt-in: imported by 8ug8ear only. Other hosts import this aggregate
  # when they need ZTNA access to Pangolin core.
  #
  # Module shape (revised after a real-world exec failure on 8ug8ear):
  #   - NixOS aggregate  : the binary `pangolin-cli` AND a
  #                        `pangolin-waybar-status` system package that
  #                        the waybar fragment invokes by absolute path.
  #   - Home Manager    : the waybar include fragment that hard-codes
  #                        the absolute exec path.
  #
  # Why a system package (not ~/...bin): waybar's `exec` calls g_spawn,
  # which inherits a minimal env (no login-shell PATH, no `~`
  # expansion). A literal `~/.local/bin/pangolin-waybar-status` exec
  # value silently fails; g_spawn sees the literal string with no
  # expansion, ENOENT, exit 127, blank waybar slot. The fix is the
  # script living at `/run/current-system/sw/bin/pangolin-waybar-status`
  # — a stable Nix-profile path that g_spawn sees at the literal name.
  #
  # Why an external file (not inlined ''...'' heredoc): Nix `''...''`
  # heredoc rules for `` ` `\` escapes are notoriously easy to get
  # wrong, especially around shell `$varname` interpolation. Keeping
  # the script as a sibling .sh file makes it readable, diffable, and
  # impervious to heredoc-escape errors. The Nix module just `cp`s it.

  flake.modules.nixos.pangolin-cli =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.pangolin-cli

        # Polling helper. Lives at /run/current-system/sw/bin/pangolin-waybar-status.
        (pkgs.writeShellScriptBin "pangolin-waybar-status" (builtins.readFile ./pangolin-waybar-status.sh))
      ];
    };

  # Home Manager: waybar include fragment.
  #
  # The exec value is the absolute path Nix exposes in the system
  # profile for writeShellScriptBin outputs. Stable Nix profile
  # symlink across rebuilds; g_spawn sees a literal path — no `~`
  # expansion, no PATH lookup.
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

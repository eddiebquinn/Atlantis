{
  # Internet / LAN reachability indicator for waybar. Companion to
  # modules/nixos/pangolin.nix — same architectural shape, different probe.
  #
  # Module shape (deliberately mirrors pangolin.nix so the two indicators
  # ship on the same footing):
  #   - System package: the polling helper `internet-waybar-status`,
  #     installed at `/run/current-system/sw/bin/internet-waybar-status`
  #     so waybar's `exec` (which uses g_spawn with a minimal env and
  #     no `~` expansion) sees it at the literal name.
  #   - Per-host waybar.jsonc: declares the `custom/internet` slot with
  #     `exec` pointing at the absolute system path.
  #
  # Why a system package (not ~/...bin): waybar's `exec` calls g_spawn,
  # which inherits a minimal env (no login-shell PATH, no `~`
  # expansion). A literal `~/.local/bin/internet-waybar-status` exec
  # value silently fails — g_spawn sees the literal string, ENOENT, exit
  # 127, blank waybar slot. Fix: the script lives at
  # `/run/current-system/sw/bin/internet-waybar-status` — a stable
  # Nix-profile path that g_spawn sees at the literal name.
  #
  # Why an external file (not inlined ''...'' heredoc): Nix `''...''`
  # heredoc rules for `` ` `\` escapes are notoriously easy to get
  # wrong, especially around shell `$varname` interpolation. Keeping
  # the script as a sibling .sh file keeps it readable, diffable, and
  # impervious to heredoc-escape errors. The Nix module just `cp`s it.

  flake.modules.nixos.internet-waybar =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        # Polling helper. Lives at /run/current-system/sw/bin/internet-waybar-status.
        (pkgs.writeShellScriptBin "internet-waybar-status" (builtins.readFile ./internet-waybar-status.sh))
      ];
    };
}

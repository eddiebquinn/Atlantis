{ lib, ... }:

# Per-system waybar overlay for the fleet.
#
# Why this exists:
#   Waybar 0.15.0 (in nixpkgs nixos-26.05) sends the bare-arg form
#   "dispatch workspace N" to the Hyprland IPC socket from
#   Workspace::handleClicked. Hyprland >= 0.54 parses the IPC dispatch
#   argument as a Lua expression, so the bare-arg form becomes
#   `return hl.dispatch(workspace N)` and bails with
#   `')' expected near 'workspace'`. Result: clicking a workspace
#   button in the bar does nothing while keyboard binds (which use the
#   modern `hl.dsp.focus({ workspace = 1 })` shape) keep working.
#
#   Upstream fix: https://github.com/Alexays/Waybar/pull/5013 (merged
#   on master, NOT yet in any tagged release). Nixpkgs still ships
#   0.15.0 from Feb 2026.
#
#   ../patches/waybar-pr5013-lua-dispatch.patch is a backport of that
#   PR's first commit (e17c0d9f0) to 0.15.0. It adds IPC::dispatch(),
#   IPC::buildLuaDispatch(), and IPC::isLuaProtocol() and routes
#   Workspace::handleClicked through IPC::dispatch so the right
#   protocol (legacy text vs Lua hl.dsp.*) is used automatically.
#
# Drop:
#   Once waybar 0.15.x is bumped to a release that includes the
#   upstream fix (likely 0.15.1 or later), delete this file, the patch,
#   and tracking issue #21. A no-op patch on already-fixed upstream
#   would compile to the same store path, but is wasteful — drop
#   cleanly instead.
{
  flake.modules.nixos.workstation = {
    # `workstation` is contributed by modules/flake/home-manager.nix
    # and merged into every host via `imports = [ ... workstation ]`
    # in each modules/hosts/<name>.nix.
    #
    # We contribute the nixpkgs.overlays list from this module so the
    # edit lives next to its purpose rather than in a generic
    # flake.nix. nixpkgs.overlays is per-host here — it propagates
    # through nixosSystem → home-manager (via useGlobalPkgs=true in
    # modules/flake/home-manager.nix) → pkgs.waybar.
    nixpkgs.overlays = lib.singleton (
      _final: prev:
      {
        waybar = prev.waybar.overrideAttrs (old: {
          patches = (old.patches or []) ++ [
            ../../patches/waybar-pr5013-lua-dispatch.patch
          ];
        });
      }
    );
  };
}

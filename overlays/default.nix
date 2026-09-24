# Per-system overlays. Add entries below.
#
# Example: patching waybar 0.15.0 for Hyprland 0.55.2 IPC compatibility.
#
# Waybar 0.15.0's `Workspace::handleClicked` sends legacy bare-arg
# dispatch strings ("dispatch workspace N") directly to the Hyprland
# IPC socket. Hyprland >= 0.54 now parses those as Lua expressions
# (`return hl.dispatch(workspace N)`), which fails with
# `')' expected near 'workspace'`. The result: clicking workspace
# buttons in the waybar does nothing on Hyprland >= 0.54.
#
# Upstream fix: https://github.com/Alexays/Waybar/pull/5013 (merged
# on master, not yet in a release; nixpkgs still ships 0.15.0).
#
# patches/waybar-pr5013-lua-dispatch.patch is a backport of that PR's
# first commit (e17c0d9f0) to 0.15.0. It adds IPC::dispatch(),
# IPC::buildLuaDispatch(), and IPC::isLuaProtocol() and routes
# Workspace::handleClicked through IPC::dispatch so the right
# protocol (legacy text vs Lua hl.dsp.*) is used automatically.
#
# Drop the patch entry once waybar 0.15.x is bumped to a release
# that includes the upstream fix (likely 0.15.1 or later).
[
  (final: prev: {
    waybar = prev.waybar.overrideAttrs (old: {
      patches = (old.patches or []) ++ [
        ../patches/waybar-pr5013-lua-dispatch.patch
      ];
    });
  })
]

## Context

The 26.05 channel pin is already on master (`7db7426`). A prior
attempt (MR !36, branch `feat/declarative-compositor`, closed
2026-09-17) tried to convert the legacy 8.4 KB `hyprland.conf` +
per-host `hosts.conf` chain into HM's Lua-form module in one shot. It
accumulated 12+ fix commits and never produced a booting session:
home-manager 26.05's Lua emitter emits shapes Hyprland 0.55's parser
rejects (monitor args, env tables, window_rule keys, col.* colors,
bind dispatchers, quoting), and each fix surfaced the next mismatch.
Hyprland's parser gives no dry-run feedback — the only signal is the
on-screen error box after a compositor start.

This change replaces conversion with a rewrite from the upstream
`example/hyprland.lua` baseline.

## Goals / Non-Goals

**Goals:**
- A declarative Hyprland session on all three hosts, built from a
  known-good parser-compatible baseline, grown one boot-verified
  addition at a time.
- Single source of truth: home-manager emits `hyprland.lua`; no
  hand-edited conf files participate in any session.
- Two-layer split preserved: compositor enablement on the NixOS layer,
  session config + packages on the home layer.
- Per-host topology (monitors, workspace banks) as host attrs.

**Non-Goals:**
- Faithful reproduction of every legacy conf knob. Missing comforts
  are follow-ups.
- Re-pinning channels (already on master).
- Waybar/wofi/hyprpaper module conversion (`atlantis-dendritic-layout`).
- Visual rice (`atlantis-dendritic-rice`).

## Decisions

- **Rewrite from the upstream example, not conversion.** The legacy
  conf is five years of accretion; translating it knob-by-knob against
  a parser with no dry-run made every change a boot-test gamble. The
  upstream `example/hyprland.lua` is maintained by Hyprland itself and
  is parser-compatible by construction. Strip it to minimal, grow it
  back. The user's usage is light; the state to reproduce is small.
- **All content via `extraConfig` raw Lua; HM typed attrs only for
  enable/configType/package.** Proven by MR !36: HM's emitter shapes
  (single-string monitor, nested env tables, bracket-string
  window_rule keys, `col.active_border` dot syntax, string bind
  dispatchers, single quotes) are all parser-rejected. Raw
  `extraConfig` mirroring the upstream example's shapes is the only
  path that worked. Typed attrs stay minimal.
- **One addition per boot-verified commit.** Parse errors are
  positional (line numbers); batched additions make the failing shape
  unattributable. Slow but diagnosable.
- **The red-box error text is the primary diagnostic.** `hyprctl`
  logs are silent on Lua parse errors; SSH screenshots go stale.
  Task discipline: capture the box text before any edit.
- **Two-layer split: slim the NixOS module, don't delete it.** The
  display manager resolves the wayland-session file before any user
  session exists, so compositor enablement stays on the system layer.
  (Carried from the prior draft; unchanged.)
- **Spider first? No — 8ug8ear first.** It is already mid-broken from
  MR !36 testing (its `~/.config/hypr/` holds the HM-generated Lua),
  it is the least critical host, and the SSH-access diagnostic loop is
  already proven there. Spider and blackhand follow once the module
  boots clean.
- **Keep the `banks` host-attr pattern.** Workspace-bank expansion
  via `lib.concatMapStringsSep` into `extraConfig` survived the MR
  !36 work structurally; it moves to the rewrite unchanged in shape.

## Risks / Trade-offs

- **Feature loss vs the legacy conf.** The rewrite is minimal-first;
  anything the user misses is a follow-up commit. Tracked by the §5
  soak, not a blocker.
- **HM emitter may fix the shapes later.** When it does, `extraConfig`
  content can migrate to typed attrs incrementally. Not this change.
- **Boot-test cadence is slow.** Each addition is a switch + reboot.
  Accepted: the alternative (batched changes) is what produced the
  MR !36 failure mode.
- **`dbus-broker` exit-4 on activation.** Known major-version jump
  artefact; reboot and re-switch. Documented in tasks.
- **Stale `.conf` shadowing.** Hyprland prefers `hyprland.conf` over
  `hyprland.lua` when both exist; the activation hook removes HM's
  stub and tasks mandate a one-time `rm -f`.

## Out of scope (intentional)

- Waybar / wofi / fastfetch / hyprpaper module conversion — see
  `atlantis-dendritic-layout`.
- Visual / theming rice — see `atlantis-dendritic-rice`.
- Migrating `extraConfig` content to HM typed attrs once the emitter
  catches up.

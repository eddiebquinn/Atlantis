## Why

The user's top-level plan includes "rice hyprland a bit more than before
so it looks less shit" as a noted, out-of-scope item — i.e. a deliberate
visual polish pass on the Hyprland session that has no specific
acceptance criteria yet. This stub exists so the item has a home in
openspec and doesn't get forgotten between change cycles; it is NOT a
commitment to do the work.

## What Changes

TBD. Open questions the user needs to answer before this can become a
real change:

- **What is "better than current"?** Color palette change, font swap,
  widget layout rework, animation tuning, wallpaper change, all of
  the above, none of the above? Without a concrete target, "rice" is
  unworkable as an openspec change.
- **Per-host or fleet-wide?** blackhand's triple-head layout,
  spider's single display, and 8ug8ear's X230 internal display are
  quite different surfaces; a single rice target may not fit all
  three.
- **Stability-soak gate.** Even cosmetic changes can regress
  compositor behaviour. This change would need the same eval +
  per-host verification windows as the declarative-compositor change.

## Capabilities

### New Capabilities

(none yet — pending user scope)

### Modified Capabilities

(none)

## Impact

Unknown until scoped. Likely candidates:

- `modules/home/hyprland.nix` (settings attrs)
- `hosts/<host>/home.nix` (per-host monitor / workspace attrs)
- `modules/home/configs/hypr/wallpapers/` (asset directory)

## Out of scope

- Any non-Hyprland visual change (terminal theme, GTK theme, cursor
  theme — those are separate concerns, would be their own changes if
  desired).
- Adding new tools (a new launcher, a new bar, a new notification
  daemon). New tools belong in `atlantis-dendritic-layout`.

## Sequencing

Blocked until the user picks a concrete rice target. Will also want
to wait for `atlantis-26-05-declarative-compositor` and
`atlantis-dendritic-layout` to land first so the rice changes happen
on the declarative substrate rather than being re-done when the
underlying config moves.

# Proposal: atlantis-session-locking

## Why

Issue #3 reports a security gap on 8ug8ear (the ThinkPad X230 laptop):
closing the lid does not lock or suspend the machine, and SUPER+l does
nothing because the chord is currently bound to focus-right (vim keys).
Today the session has **no lock screen at all** — no hyprlock, no
hypridle, no logind lid policy. Anyone opening the lid or sitting down
at an unlocked session gets full access.

A prior attempt (reverted) used `services.logind.lidSwitch = "lock"`:
closing the lid locked, but reopening produced a black screen — no lock
UI, no DPMS restore, no compositor output recovery. The root cause is
that logind's `lock` action sends a session Lock signal that nothing in
the session listens to, while displays stayed off with nothing to wake
them into.

## What Changes

- **New capability `session-locking`** (this change): the session SHALL
  have a working lock screen (hyprlock), idle-triggered locking after
  10 minutes (hypridle), a manual SUPER+l lock bind, and suspend-on-lid
  on 8ug8ear with resume-into-lock-screen.
- New file `modules/lock.nix` — the lock feature across both layers:
  - NixOS `workstation` aggregate: `programs.hyprlock.enable = true`
    (package + PAM service, required for auth).
  - home-manager `eddie` aggregate: `services.hypridle` (idle 600s →
    lock; before-sleep → lock; after-resume → DPMS on) and the
    `hyprlock.conf` lock UI (Tokyo-Night palette, session wallpaper).
- `modules/hyprland.nix`: SUPER+l now runs `pidof hyprlock || hyprlock`
  (idempotent — won't double-spawn); vim focus-right moves to
  SUPER+CTRL+l.
- `modules/hosts/8ug8ear.nix`: logind lid policy — `lidSwitch =
  "suspend"` (battery and AC), `lidSwitchDocked = "ignore"`. The
  laptop suspends when the lid closes; hypridle's before_sleep_cmd has
  already locked the screen, so resume lands on the lock screen.

### Bind conflict resolution

SUPER+l was focus-right. Options were presented to the user
(SUPER+SHIFT+L lock / move focus / drop focus / SUPER+ESC); no
response within the window, so the default applied: **SUPER+l = lock**
(the explicit request in issue #3), **focus-right → SUPER+CTRL+l**.
Vetoable in MR review with a one-line revert.

## Capabilities

### New Capabilities
- `session-locking` — lock screen, idle lock, manual lock bind, and
  laptop suspend-on-lid with resume-into-lock.

### Modified Capabilities

(none — the compositor-config spec has no requirement covering the
bind surface, so there is nothing to modify; the SUPER+l bind contract
is introduced as part of `session-locking`.)

## Impact

- `modules/lock.nix` (new) — lock stack, both layers, one file.
- `modules/hyprland.nix` — bind changes only (2 lines + comment).
- `modules/hosts/8ug8ear.nix` — logind lid policy block.
- All three hosts get the lock stack (software repo-wide feature per
  the 8ug8ear-first-is-order-not-scope rule); only 8ug8ear gets the
  lid/suspend policy (hardware-specific).

## Out of scope

- Display-manager-based locking (ly handles pre-login only).
- Any other bind changes; no idle *logout*, idle suspend, or dimming
  beyond the 630s DPMS-off listener.
- spider / blackhand suspend or lid behaviour (no lids).
- Lock screen theming beyond matching the existing Tokyo-Night
  palette.

## Why an OpenSpec change (and not a small issue+MR)

The user explicitly requested an OpenSpec ("Please create an openspec
if necessary"). It is necessary: this change spans two layers
(NixOS + HM), three files, introduces a new capability with acceptance
criteria drawn from the issue, and modifies the compositor-config
spec's bind contract.

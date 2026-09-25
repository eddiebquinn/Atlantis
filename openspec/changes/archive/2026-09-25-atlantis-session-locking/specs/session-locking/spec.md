## ADDED Requirements

### Requirement: Session Lock Screen Exists and Authenticates

The session SHALL provide a lock screen (hyprlock) on every host,
authenticating against the user's login password via PAM. The lock
UI config SHALL live in the home-manager `eddie` aggregate; the PAM
service and package SHALL be enabled on the NixOS `workstation`
aggregate (`programs.hyprlock.enable = true`). The display manager
(ly) SHALL NOT be involved in session locking (pre-login only).

#### Scenario: Manual lock shows the lock screen
- **WHEN** the user presses SUPER+l in an active Hyprland session
- **THEN** hyprlock launches and shows the lock screen
- **AND** entering the correct password returns to the session

#### Scenario: Lock is idempotent
- **WHEN** hyprlock is already running and the lock bind or an idle
  listener fires again
- **THEN** no second hyprlock instance spawns (`pidof hyprlock ||
  hyprlock` guard)

### Requirement: Idle Locking After 10 Minutes

The session SHALL lock automatically after 10 minutes of idle
(hypridle listener, timeout 600s). The session SHALL blank displays
(DPMS off) 30 seconds after locking, and SHALL restore displays (DPMS
on) on any input while locked.

#### Scenario: 10-minute idle triggers lock
- **WHEN** the session is idle for 600 seconds
- **THEN** hyprlock launches and the lock screen is shown

#### Scenario: Display blanking after lock
- **WHEN** the session has been locked and idle for a further 30
  seconds
- **THEN** displays turn off
- **AND** any input turns displays back on into the lock screen

### Requirement: Suspend-on-Lid on the Laptop, Resume Into Lock

On 8ug8ear, closing the lid SHALL suspend the machine (logind
`lidSwitch = "suspend"`, battery and AC; docked = ignore). hypridle's
`before_sleep_cmd` SHALL lock the session before the system sleeps, so
resuming (lid open) lands on the lock screen — never a black screen.
`after_sleep_cmd` SHALL re-enable DPMS on resume.

#### Scenario: Lid close suspends and resume shows the lock screen
- **WHEN** the lid is closed on 8ug8ear
- **THEN** the session locks (before_sleep_cmd) and the machine
  suspends
- **AND** on lid open the machine resumes into the lock screen with
  displays on

#### Scenario: Black screen never reappears on resume
- **WHEN** the machine resumes from suspend
- **THEN** the lock screen is visible within a few seconds of display
  re-init
- **AND** no display-manager prompt or black screen appears

### Requirement: Manual Lock Bind

SUPER+l SHALL lock the session (idempotent launcher). Focus-right —
previously SUPER+l — SHALL move to SUPER+CTRL+l. The bind surface
SHALL stay in `modules/hyprland.nix`.

#### Scenario: SUPER+l locks
- **WHEN** SUPER+l is pressed in an active session
- **THEN** the session locks

#### Scenario: Vim focus binds survive
- **WHEN** SUPER+CTRL+l is pressed
- **THEN** focus moves right
- **AND** SUPER+h / SUPER+j / SUPER+k are unchanged

### Requirement: Lock Screen Appearance

The session SHALL render a centred authenticate box as the lock
screen — adapted from Layout 17 of
[mahaveergurjar/Hyprlock-Dots](https://github.com/mahaveergurjar/Hyprlock-Dots),
with the host's hostname in the title bar and the user's login name
on the username label. The layout SHALL live in
`modules/hyprland/hyprlock-themed.conf` and be wired via
`xdg.configFile."hypr/hyprlock.conf".source` so the lock UI is
rebuildable without a shell hack. `atlantis.lock.style` SHALL remain
a reserved option (currently enum `["themed"]`) so future variants
can be added without another rename pass.

#### Scenario: Lock screen renders the hostname in the title
- **WHEN** the session locks on 8ug8ear
- **THEN** the centred authenticate box shows "Authenticate into
  8ug8ear" in the title bar
- **AND** the username label shows "Username: eddie"

#### Scenario: Lock screen renders on every host
- **WHEN** the user profile is activated on any host
- **THEN** `~/.config/hypr/hyprlock.conf` is a symlink to the themed
  conf in the Nix store

#### Scenario: Lock screen mirrors the ly display manager aesthetic
- **WHEN** the user transitions from ly (pre-login) into the locked
  session
- **THEN** the visual continuity between ly and the lock screen
  feels coherent (centred box, monochrome palette, no decorative
  chrome)

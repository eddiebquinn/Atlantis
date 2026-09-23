# ❄️ Atlantis
Declarative personal infrastructure built on Nix, Git, and cryptographic identity.

> ⚠️ **Read-Only Mirror**
> This repository is a public projection for portfolio purposes.
> The canonical source of truth lives on my self-managed GitLab infrastructure.
> Running systems are built from that source.

## Overview
Atlantis is a long-lived operating environment designed to be:
- Predictable
- Auditable
- Reproducible
- Low-maintenance

If a machine disappears, it should be rebuildable from Git without stress.
The repository is the source of truth; Running systems are ephemeral.

## Core Principles
- Declarative over imperative
- Configuration over commands
- Version control over tribal knowledge
- Recovery over heroics

If it cannot be rebuilt from Git + Nix, it does not belong.

## Architecture
Atlantis is built on:
- **NixOS** — system configuration, services, hardware policy
- **Home-Manager** — user environment and workflow configuration
- **flake-parts + import-tree** — the [dendritic pattern](https://github.com/mightyiam/dendritic):
  every `.nix` file under `modules/` is a flake-parts module, imported
  automatically. There are no hand-maintained `imports = [ ... ]` lists of
  repo-local paths — the directory tree *is* the import graph.
- **Git** — canonical system state and audit trail
- **GPG / SSH** — explicit identity and trust boundaries

System and user concerns are strictly separated.

## Repository layout

```
modules/
  flake/     # systems, host assembly, home-manager glue
  hosts/     # one file per machine + its hardware and assets
  nixos/     # NixOS-layer features
  home/      # home-manager-layer features
  hyprland.nix   # a feature that spans both layers, in one file
```

Modules contribute to named aggregates rather than being imported by path:

- `flake.modules.nixos.workstation` — everything all three hosts share
- `flake.modules.nixos.{audio,nvidia,kube,gaming}` — opt-in, per host
- `flake.modules.homeManager.eddie` — the user environment

A host file imports the aggregates it wants and declares only what is true
of that machine. Adding a feature means adding a file; nothing else changes.

## What This Demonstrates
- Infrastructure as Code (flake-based Nix)
- Atomic upgrades and rollbacks
- Reproducible workstation builds
- Cryptographic identity hygiene
- Git-driven configuration workflows
- Long-term maintainability mindset

## Recovery Philosophy
The design goal is boring rebuilds.

Failure should be:
- Contained
- Reversible
- Documented
- Calm
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
- **Git** — canonical system state and audit trail
- **GPG / SSH** — explicit identity and trust boundaries

System and user concerns are strictly separated.

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
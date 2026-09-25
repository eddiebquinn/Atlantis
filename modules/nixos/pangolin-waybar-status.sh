#!/usr/bin/env bash
# pangolin-waybar-status — waybar polling helper for the Pangolin ZTNA
# client. Prints a one-line JSON document to stdout for waybar's
# `custom/pangolin` module (`return-type: "json"`).
#
# Probe order (cheapest first):
#   1. ip -br addr show pangolin — non-empty means the tunnel interface
#      is up. Free, no subprocess. Matches ground truth from 8ug8ear
#      where the interface is named exactly `pangolin`.
#   2. pangolin status --json | jq '.connected and .registered' — the CLI
#      authoritative answer. Requires the `jq` binary in PATH.
#   3. Fallback: not connected.
#
# Output (one JSON object per line, valid for waybar's `return-type: "json"`):
#   {"text": "● pangolin", "tooltip": "...", "class": "connected"}
#
# The `class` field drives CSS in ~/.config/waybar/style.css:
#   #custom-pangolin.connected       { color: ...; }  /* green  */
#   #custom-pangolin.disconnected   { color: ...; }  /* red/dim */

set -euo pipefail

emit() {
  local cls="$1" tip="$2" txt="$3"
  printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$txt" "$tip" "$cls"
}

# 1. Interface up? Cheapest signal — no fork, no jq.
if ip -br addr show pangolin 2>/dev/null | grep -q .; then
  emit connected 'Pangolin tunnel interface is up' '● pangolin'
  exit 0
fi

# 2. CLI status (only runs if `pangolin` and `jq` exist).
if command -v pangolin >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
  if pangolin status --json | jq -e '.connected and .registered' >/dev/null 2>&1; then
    emit connected 'Pangolin connected' '● pangolin'
    exit 0
  fi
fi

# 3. Fallback.
emit disconnected 'Pangolin not connected' '● pangolin'
exit 0

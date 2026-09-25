#!/usr/bin/env bash
# internet-waybar-status — waybar polling helper for connectivity state.
# Prints a one-line JSON document to stdout for waybar's
# `custom/internet` module (`return-type: "json"`).
#
# State machine (cheapest signal wins):
#   offline   — no non-loopback link UP
#   lan       — link UP, but no default route OR external probe (DNS / HTTPS) fails
#   internet  — link UP, default route present, AND external probe succeeds
#
# Probe order (cheapest first):
#   1. ip -br addr show — any non-lo, UP interface? no → offline.
#   2. ip -4 route show default — present? if yes, candidate for "internet".
#   3. getent hosts cloudflare.com → /etc/resolv.conf + systemd-resolved path.
#      If DNS works, we are most of the way to "internet" already.
#      If DNS is broken (or absent), fall back to a direct HTTPS probe:
#        curl -fsS --max-time 3 https://1.1.1.1/cdn-cgi/trace
#      That endpoint is a Cloudflare trace page, ~250 B, no JS, no cookies.
#   4. Default route AND any successful probe → "internet". Otherwise "lan".
#
# Output (one JSON object per line, valid for waybar's `return-type: "json"`):
#   {"text": "λ", "tooltip": "...", "class": "internet|lan|offline"}
#
# The `class` field drives CSS in ~/.config/waybar/style.css:
#   #custom-internet.internet    { color: ...; border-bottom: ...; }  /* green  */
#   #custom-internet.lan         { color: ...; border-bottom: ...; }  /* yellow */
#   #custom-internet.offline     { color: ...; border-bottom: ...; }  /* dim    */
#
# Why `λ` (U+03BB): identity marker, single-glyph, font-safe. Distinct from
# the pangolin module's `∋` (U+220B) on purpose — different families so each
# module can evolve independently without dragging the other.

set -euo pipefail

emit() {
  local cls="$1" tip="$2" txt="$3"
  printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$txt" "$tip" "$cls"
}

# 1. No link at all? offline.
#
# `ip -br addr show` emits one line per interface (no header row in -br mode),
# state column has the form `UP`, `UNKNOWN`, `DOWN`, etc.
# `ip -br addr show up` (the `up` qualifier is a free filter) drops DOWN rows
# for us, but it still includes `lo`. So we pipe the result to awk and
# explicitly exclude loopback. The awk pattern is bare-positive: any non-lo
# interface starts with `<name>  UP` → exit 0 immediately. If awk walks the
# whole stream without seeing one, it exits 1.
#
# Why not put the loopback exclusion in a regex? `lo` is short and matches
# things like `wlan0` or `wlo1`. Word-boundary exclusion is hard to do
# correctly in awk without breaking readability. Two-stage filter is clearer.
if ! ip -br addr show up 2>/dev/null \
     | awk '$1 != "lo" {found=1; exit 0} END {exit !found}'; then
  emit offline 'No LAN link' 'λ'
  exit 0
fi

# 2/3. Default route + external probe.
#
# Default route:
#   if `ip -4 route show default` returns any line → default=yes. Otherwise no.
# We use a function-on-each-side pattern instead of `set -e` because we want
# BOTH branches: success isn't an error, missing default isn't either.
default=no
if ip -4 route show default 2>/dev/null | grep -q .; then
  default=yes
fi

probe_ok=no
# DNS path — cheap, synchronous.
if command -v getent >/dev/null 2>&1 \
   && getent hosts cloudflare.com >/dev/null 2>&1; then
  probe_ok=yes
# Direct HTTPS fallback when DNS is broken (e.g. missing/misconfigured resolver).
elif command -v curl >/dev/null 2>&1 \
   && curl -fsS --max-time 3 https://1.1.1.1/cdn-cgi/trace >/dev/null 2>&1; then
  probe_ok=yes
fi

if [ "$default" = "yes" ] && [ "$probe_ok" = "yes" ]; then
  emit internet 'Internet reachable' 'λ'
  exit 0
fi

emit lan 'LAN only — no internet' 'λ'
exit 0

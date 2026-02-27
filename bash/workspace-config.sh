#!/usr/bin/env bash
# workspace-config.sh
# Control monitor routing between laptop (USB-C) and desktop (HDMI).
#
# Usage:
#   ./workspace-config.sh laptop    - reconnect monitor to macOS + switch to USB-C
#   ./workspace-config.sh desktop   - soft-disconnect from macOS + switch to HDMI 1
#
# CONFIGURATION — edit these to match your setup
# ─────────────────────────────────────────────────────────────────────────────
MONITOR_NAME="DELL S3425DW"   # Partial name match (case-insensitive)
INPUT_USBC=27                 # DDC input code for USB-C (your laptop)
INPUT_HDMI1=17                # DDC input code for HDMI 1 (your desktop)
SWITCH_DELAY=2                # Seconds to wait between steps
# ─────────────────────────────────────────────────────────────────────────────

BD="/Applications/BetterDisplay.app/Contents/MacOS/BetterDisplay"
if command -v betterdisplaycli &>/dev/null; then
  BD="betterdisplaycli"
fi

if [[ ! -x "$BD" ]] && [[ "$BD" != "betterdisplaycli" ]]; then
  echo "❌  BetterDisplay not found at $BD"
  echo "    Install BetterDisplay or: brew install waydabber/betterdisplay/betterdisplaycli"
  exit 1
fi

run() {
  echo "▶  $BD $*"
  "$BD" "$@"
}

case "${1:-}" in
  laptop)
    echo "💻  Laptop mode: switching input to USB-C and reconnecting monitor to macOS…"
    run set -namelike="$MONITOR_NAME" -ddc="$INPUT_USBC" -vcp=inputSelect
    sleep "$SWITCH_DELAY"
    run set -namelike="$MONITOR_NAME" -connected=on
    echo "✅  Monitor connected to macOS on USB-C."
    ;;

  desktop)
    echo "🖥️  Desktop mode: soft-disconnecting monitor from macOS and switching to HDMI 1…"
    run set -namelike="$MONITOR_NAME" -connected=off
    sleep "$SWITCH_DELAY"
    run set -namelike="$MONITOR_NAME" -ddc="$INPUT_HDMI1" -vcp=inputSelect
    echo "✅  Monitor removed from macOS layout and switched to HDMI 1."
    ;;

  *)
    echo "Usage: $0 <mode>"
    echo ""
    echo "  laptop   Reconnect monitor to macOS + switch to USB-C input"
    echo "  desktop  Soft-disconnect monitor from macOS + switch to HDMI 1"
    exit 1
    ;;
esac
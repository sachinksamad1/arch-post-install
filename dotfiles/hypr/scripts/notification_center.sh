#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║             Notification Center Controller                  ║
# ║     SwayNotificationCenter (swaync) & Dunst Fallback         ║
# ╚══════════════════════════════════════════════════════════════╝

set -euo pipefail

ACTION="${1:-toggle}"

case "$ACTION" in
  toggle)
    if command -v swaync-client >/dev/null 2>&1; then
      swaync-client -t -sw
    elif command -v dunstctl >/dev/null 2>&1; then
      dunstctl history-pop
    else
      notify-send "Notification Center" "No notification center daemon found (install swaync)" -i dialog-information
    fi
    ;;
  open)
    if command -v swaync-client >/dev/null 2>&1; then
      swaync-client -op -sw
    elif command -v dunstctl >/dev/null 2>&1; then
      dunstctl history-pop
    fi
    ;;
  close)
    if command -v swaync-client >/dev/null 2>&1; then
      swaync-client -cp -sw
    elif command -v dunstctl >/dev/null 2>&1; then
      dunstctl close-all
    fi
    ;;
  dnd)
    if command -v swaync-client >/dev/null 2>&1; then
      swaync-client -d -sw
    elif command -v dunstctl >/dev/null 2>&1; then
      dunstctl set-paused toggle
    fi
    ;;
  clear)
    if command -v swaync-client >/dev/null 2>&1; then
      swaync-client -C
      swaync-client -c
    elif command -v dunstctl >/dev/null 2>&1; then
      dunstctl history-clear
      dunstctl close-all
    fi
    ;;
  reload)
    if command -v swaync-client >/dev/null 2>&1; then
      swaync-client -rs 2>/dev/null || swaync-client -R 2>/dev/null || true
    fi
    ;;
  *)
    echo "Usage: $0 [toggle|open|close|dnd|clear|reload]"
    exit 1
    ;;
esac

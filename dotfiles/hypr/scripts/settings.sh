#!/usr/bin/env bash
# ╔══════════════════════════════════════╗
# ║           Settings Menu              ║
# ║      Edit Hyprland Configurations    ║
# ╚══════════════════════════════════════╝

set -euo pipefail

HYPR_DIR="$HOME/.config/hypr"
SCRIPTS_DIR="$HOME/.config/hypr/scripts"
TERM_APP="${TERMINAL:-kitty}"

# Menu entries with Nerd Font icons
options="󰌍  Control Center Menu
󰌌  Input Settings
󰌓  Key Bindings
󱕰  Additional Bindings
󰍹  Monitor Settings
󰒲  Hypridle Settings
󰂎  Power Management (Hyprlock)
󰂚  Notification Settings"

# Show the rofi menu
selection=$(echo -e "$options" | rofi -dmenu -i \
  -p "  Settings" \
  -mesg "  Hyprland Configuration Editor" \
  -theme ~/.config/rofi/floating-menu.rasi)

# Handle selection
case "$selection" in
*"Control Center Menu"*)
  bash "$SCRIPTS_DIR/floating_menu.sh"
  ;;
*"Input Settings"*)
  $TERM_APP --title "Input Settings" --class large-floating-term nvim "$HYPR_DIR/config/input.lua"
  ;;
*"Key Bindings"*)
  $TERM_APP --title "Key Bindings" --class large-floating-term nvim "$HYPR_DIR/config/keybinds/core.lua"
  ;;
*"Additional Bindings"*)
  $TERM_APP --title "Additional Bindings" --class large-floating-term nvim "$HYPR_DIR/config/keybinds/utilities.lua"
  ;;
*"Monitor Settings"*)
  $TERM_APP --title "Monitor Settings" --class large-floating-term nvim "$HYPR_DIR/config/monitors.lua"
  ;;
*"Hypridle Settings"*)
  $TERM_APP --title "Hypridle Settings" --class large-floating-term nvim "$HYPR_DIR/hypridle.conf"
  ;;
*"Power Management"*)
  $TERM_APP --title "Power Management" --class large-floating-term nvim "$HYPR_DIR/hyprlock.conf"
  ;;
*"Notification Settings"*)
  if [ -f "$HOME/.config/swaync/config.json" ]; then
    $TERM_APP --title "Notification Settings" --class large-floating-term nvim "$HOME/.config/swaync/config.json"
  elif [ -f "$HOME/.config/dunst/dunstrc" ]; then
    $TERM_APP --title "Notification Settings" --class large-floating-term nvim "$HOME/.config/dunst/dunstrc"
  else
    $TERM_APP --title "Notification Settings" --class large-floating-term nvim "$HOME/.config/swaync/config.json"
  fi
  ;;
esac

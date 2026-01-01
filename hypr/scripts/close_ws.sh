#!/usr/bin/env bash
set -euo pipefail

WS="${1:-}"
icon="$HOME/.config/hypr/icons/close.png"
# -------- Validation --------
# Check if a workspace ID was passed
if [[ -z "$WS" ]]; then
	notify-send "Hyprland" "No workspace number provided" -i $icon
	exit 1
fi

# Check if hyprctl exists
if ! command -v hyprctl &>/dev/null; then
	notify-send "Hyprland" "hyprctl not found" -i $icon
	exit 1
fi

# Check if jq exists
if ! command -v jq &>/dev/null; then
	notify-send "Hyprland" "jq not installed" -i $icon
	exit 1
fi

# Check workspace exists and has windows
CLIENTS=$(hyprctl clients -j | jq -r ".[] | select(.workspace.id==$WS) | .address")

if [[ -z "$CLIENTS" ]]; then
	notify-send "Hyprland" "ℹ Workspace $WS is already empty (or does not exist)"
	exit 0
fi

# -------- Main Action --------
while read -r addr; do
	[[ -z "$addr" ]] && continue
	hyprctl dispatch closewindow address:"$addr"
done <<<"$CLIENTS"

notify-send "Hyprland" "🧹 Workspace $WS closed (windows killed)"
exit 0

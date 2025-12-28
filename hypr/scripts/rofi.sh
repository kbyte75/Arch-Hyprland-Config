#!/usr/bin/env bash
set -euo pipefail

if [[ $# -eq 0 ]]; then
	echo "Usage: $0 [clipboard|launcher]"
	echo "  clipboard : Toggle clipboard history"
	echo "  launcher  : Toggle application launcher"
	exit 0
fi

case "$1" in
clipboard)
	if pgrep -x rofi >/dev/null; then
		pkill rofi
	else
		if command -v cliphist >/dev/null; then
			selection=$(cliphist list | rofi -dmenu -p "󱉫 " -display-columns 2 -theme clipboard.rasi)
			[[ -n "$selection" ]] && echo "$selection" | cliphist decode | wl-copy
		else
			content=$(wl-paste 2>/dev/null || echo "Clipboard is empty")
			notify-send "Clipboard" "$content" -t 8000
		fi
	fi
	;;
launcher)
	if pgrep -x rofi >/dev/null; then
		pkill rofi
	else
		rofi -show drun -theme launcher.rasi
	fi
	;;

*)
	echo "Invalid option: $1" >&2
	echo "Usage: $0 [clipboard|launcher]" >&2
	exit 1
	;;
esac

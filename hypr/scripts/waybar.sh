#!/usr/bin/env bash
if [ "$1" = "reload" ]; then
	# killall waybar
	# waybar &
	# waybar -c ~/.config/waybar/vertical/config.jsonc -s ~/.config/waybar/vertical/style.css
	# notify-send "Waybar Reloaded" -i $HOME/.config/hypr/icons/check.png -r 9996
	killall -SIGUSR2 waybar
	exit 0
fi

# Toggle
if pgrep -x waybar >/dev/null; then
	killall waybar
else
	waybar &
fi

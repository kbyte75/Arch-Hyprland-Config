#!/bin/bash
if [ "$1" = "reload" ]; then
  killall waybar
  waybar &
  notify-send "Waybar Reloaded" -i $HOME/.config/hypr/icons/check.png -r 9996 
  exit 0
fi

# Toggle
if pgrep -x waybar > /dev/null; then
  killall waybar
else
  waybar &
fi
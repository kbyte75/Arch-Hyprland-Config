#!/usr/bin/env bash

CONFIG="$HOME/.config/rofi/scripts/websites.conf"

# Show ONLY titles (no URLs)
CHOICE=$(cut -d'|' -f1 "$CONFIG" | rofi -dmenu -p " " -theme web_launcher.rasi)

[ -z "$CHOICE" ] && exit 0

# Match selected title → get URL
URL=$(awk -F'|' -v choice="$CHOICE" '$1 == choice {print $2}' "$CONFIG")

[ -n "$URL" ] && xdg-open "$URL"

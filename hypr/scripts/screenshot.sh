#!/usr/bin/env bash

set -euo pipefail

DIR="${XDG_PICTURES_DIR:-"$HOME/Pictures/Screenshots"}"
# Create folder if not exists
[[ -d "$DIR" ]] || mkdir -p "$DIR"

FILE="Screenshot_$(date +%Y%m%d_%H%M%S).png"
OUTPUT_DIR="$DIR/$FILE"

case "${1:-}" in
    full)    grim "$OUTPUT_DIR" ;;
    region)  grim -g "$(slurp)" "$OUTPUT_DIR" ;;
    window)
        geom=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
        grim -g "$geom" "$OUTPUT_DIR"
        ;;
    *)       echo "arguments:[full|region|window]"; exit 1 ;;
esac

notify-send "Screenshot saved in" " $OUTPUT_DIR" -i $HOME/.config/hypr/icons/screen.png
# wl-copy < "$OUTPUT_DIR"
echo "$OUTPUT_DIR"
#!/usr/bin/env bash
set -euo pipefail

#!/usr/bin/env bash
set -euo pipefail

# Toggle rofi
if pgrep -x rofi >/dev/null; then
	pkill rofi
	exit 0
fi

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
CACHE_DIR="$HOME/.cache/rofi-wallpapers"
ROFI_THEME="$HOME/.config/rofi/wallpaper.rasi"
WALLPAPER_SCRIPT="$HOME/.config/hypr/scripts/random_wallpaper.sh"
THUMB_SIZE="400x400"

mkdir -p "$CACHE_DIR"
# Generate thumbnails (cached)
shopt -s nullglob
for img in "$WALLPAPER_DIR"/*.{jpg,jpeg,png,webp}; do
	thumb="$CACHE_DIR/$(basename "$img")"

	if [[ ! -f "$thumb" ]]; then
		magick "$img" \
			-resize "${THUMB_SIZE}^" \
			-gravity center \
			-extent "$THUMB_SIZE" \
			"$thumb"
	fi
done
shopt -u nullglob

# Rofi selection menu
SELECTION=$(
	for img in "$CACHE_DIR"/*; do
		name="$(basename "$img")"
		printf '%s\x00icon\x1f%s\n' "$name" "$img"
	done | rofi -dmenu -theme "$ROFI_THEME" -p "󰸉 "
)
[[ -z "$SELECTION" ]] && exit 0

# Apply wallpaper
WALLPAPER="$WALLPAPER_DIR/$SELECTION"

if [[ ! -f "$WALLPAPER" ]]; then
	notify-send "Wallpaper not found" "$WALLPAPER" -u critical
	exit 1
fi

exec "$WALLPAPER_SCRIPT" -path "$WALLPAPER"

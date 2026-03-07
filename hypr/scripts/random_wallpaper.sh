#!/usr/bin/env bash
set -euo pipefail

swww clear-cache

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
ICON_ERROR="$HOME/.config/hypr/icons/close.png"

TRANSITIONS=("wipe" "grow" "center" "outer" "wave")

# -----------------------------------------------------------------------------
# Functions
# -----------------------------------------------------------------------------
show_help() {
	cat <<EOF
Usage: wallpaper.sh [OPTION]

Options:
  -random                Select random wallpaper with random transition
  -path <image_path>     Set specific wallpaper with random transition
  -h, --help             Show this help message

Examples:
  wallpaper.sh -random
  wallpaper.sh -path ~/Pictures/Wallpapers/wall.png
EOF
}

notify_error() {
	notify-send "$1" "${2:-}" -i "$ICON_ERROR" -r 9996 -u critical
}

random_transition() {
	echo "${TRANSITIONS[$RANDOM % ${#TRANSITIONS[@]}]}"
}

random_wallpaper() {
	current_wallpaper="$(swww query | sed -n 's/.*image: //p')"

	find "$WALLPAPER_DIR" -type f \( \
		-iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \
		\) ! -path "$current_wallpaper" |
		shuf -n 1
}

# -----------------------------------------------------------------------------
# Argument parsing
# -----------------------------------------------------------------------------
[[ $# -eq 0 ]] && show_help && exit 0

case "${1:-}" in
-h | --help)
	show_help
	exit 0
	;;
-random)
	if [[ ! -d "$WALLPAPER_DIR" ]]; then
		notify_error "Wallpaper directory not found" "$WALLPAPER_DIR"
		exit 1
	fi
	WALLPAPER="$(random_wallpaper)"
	echo $WALLPAPER
	if [[ -z "$WALLPAPER" ]]; then
		notify_error "No images found in" "$WALLPAPER_DIR"
		exit 1
	fi
	;;
-path)
	if [[ -z "${2:-}" ]]; then
		notify_error "No image path provided"
		exit 1
	fi

	WALLPAPER="$2"
	if [[ ! -f "$WALLPAPER" ]]; then
		notify_error "Wallpaper file not found" "$WALLPAPER"
		exit 1
	fi
	;;
*)
	echo "Unknown option: $1"
	show_help
	exit 1
	;;
esac

# -----------------------------------------------------------------------------
# Apply wallpaper
# -----------------------------------------------------------------------------
TRANSITION="$(random_transition)"

if ! swww img "$WALLPAPER" \
	--transition-type "$TRANSITION" \
	--transition-fps 60 \
	--transition-duration 2.4 \
	--transition-bezier .42,0,.58,1; then

	notify_error "Failed to apply wallpaper with swww"
	exit 1
fi

# -----------------------------------------------------------------------------
# Run matugen
# -----------------------------------------------------------------------------
if ! matugen image "$WALLPAPER"; then
	notify_error "Matugen failed to process wallpaper"
	exit 1
fi

echo "Wallpaper set:"
echo "  Image      : $WALLPAPER"
echo "  Transition : $TRANSITION"

exit 0

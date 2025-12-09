#!/bin/bash

# Directory for wallpapers
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
# Array of transition types
TRANSITIONS=("wipe" "grow" "center" "outer" "wave")

# Check if directory exists
if [[ ! -d "$WALLPAPER_DIR" ]]; then
  echo "Error: Directory $WALLPAPER_DIR does not exist."
  notify-send "'~/Pictures/Wallpapers' folder not found" -i $HOME/.config/hypr/icons/close.png -r 9996 -u critical
  exit 1
fi

# Select random wallpaper
WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)
if [[ -z "$WALLPAPER" ]]; then
  echo "Error: No files found in $WALLPAPER_DIR."
  exit 1
fi

# Select random transition
TRANSITION=${TRANSITIONS[$RANDOM % ${#TRANSITIONS[@]}]}

# Apply wallpaper with swww
if ! swww img "$WALLPAPER" --transition-type "$TRANSITION" --transition-fps 60 --transition-duration 2 --transition-bezier .42,0,.58,1; then
  echo "Error: Failed to apply wallpaper with swww."
  exit 1
fi

# Run matugen for color scheme
if ! matugen image "$WALLPAPER"; then
  echo "Error: matugen failed to process $WALLPAPER."
  exit 1
fi

echo "Wallpaper set: $WALLPAPER with transition: $TRANSITION"
exit 0
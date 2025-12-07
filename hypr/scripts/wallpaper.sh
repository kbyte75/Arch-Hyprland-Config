#!/bin/bash
dir="$HOME/Pictures/Wallpapers"
file=$(find "$dir" -type f | shuf -n 1)
echo "$file"
matugen image $file
# swww img $file --transition-fps 60 --transition-type random --transition-duration 2   --transition-bezier .42,0,.58,1
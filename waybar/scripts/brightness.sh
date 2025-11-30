#!/bin/bash
# ~/.config/waybar/scripts/brightness.sh

CACHE="/tmp/current-brightness"
[[ -f "$CACHE" ]] && current=$(cat "$CACHE") || current=50
step=5
icon="$HOME/.config/hypr/icons/sun.png"

case $1 in
    up)
        new_volume=$((current + step))
        [[ $new_volume -gt 100 ]] && new_volume=100
        ;;
    down)
        new_volume=$((current - step))
        [[ $new_volume -lt 0 ]] && new_volume=0
        ;;
    *) exit 1 ;;
esac

# Apply instantly
ddcutil setvcp 10 $new_volume --bus 0 --noverify --async & >/dev/null 2>&1 &

# Cache new_volume value
echo $new_volume > "$CACHE"
notify_text="BRIGHTNESS               $new_volume%"

# Super fast OSD
killall -q notify-osd 2>/dev/null  # optional: kill old ones

 if [ "$new_volume" -eq 0 ]; then
        notify-send "$notify_text" -i "$icon" -r 9998
    else
        notify-send "$notify_text" -i "$icon" \
            -h int:value:"$new_volume" -r 9998
    fi

exit 0 
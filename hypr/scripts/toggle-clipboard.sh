#!/bin/bash
# Show clipboard content in a nice floating notification (supports Bangla)

CONTENT=$(wl-paste 2>/dev/null || echo "Clipboard is empty!")

# Use rofi (if installed) for beautiful display
if command -v rofi >/dev/null; then
    cliphist list | rofi -dmenu -p "Clipboard" -theme-str 'window {width: 500;}' | cliphist decode | wl-copy
else
    # Fallback: notify-send (scrollable)
    notify-send "Clipboard" "$CONTENT" -t 8000
    fi
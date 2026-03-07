#!/bin/bash

case "$1" in
    bluetooth)
        if pgrep -f blueman-manager > /dev/null; then
            killall blueman-applet blueman-tray blueman-manager 2>/dev/null
        else
            killall nm-connection-editor blueman-applet blueman-tray 2>/dev/null
            blueman-applet &>/dev/null &
            sleep 0.3
            blueman-manager &
        fi
        ;;
    wifi)
        if pgrep -f nm-connection-editor > /dev/null; then
            killall nm-connection-editor blueman-applet blueman-tray 2>/dev/null
        else
            killall blueman-manager blueman-applet blueman-tray 2>/dev/null
            nm-connection-editor &
        fi
        ;;
    *)
        echo "Usage: $0 [bluetooth|wifi]"
        exit 1
        ;;
esac
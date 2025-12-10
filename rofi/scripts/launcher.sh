#!/bin/bash
if pgrep -x rofi > /dev/null; then
    pkill rofi
    exit
fi

rofi -show drun -hover-select -theme launcher.rasi -no-click-to-exit false
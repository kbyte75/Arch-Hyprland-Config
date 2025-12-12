#!/bin/bash
if pgrep -x rofi > /dev/null; then
    pkill rofi
    exit
fi

rofi  -show drun -theme launcher.rasi
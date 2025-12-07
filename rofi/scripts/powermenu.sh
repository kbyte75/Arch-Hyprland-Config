# CMDs
# uptime="$(uptime -p | sed -e 's/up //g')"

# Options
lock='󰌾'
suspend='󰤁'
logout='󰿅'
shutdown='󰐥'
reboot='󰜉'

# Rofi CMD
rofi_cmd() {
    rofi -dmenu \
        -theme "~/.config/rofi/powermenu.rasi"
}

# Pass variables to rofi dmenu
run_rofi() {
    echo -e "$lock\n$suspend\n$logout\n$reboot\n$shutdown" | rofi_cmd
}

# Execute Command (no confirmation - always proceed)
run_cmd() {
	
    if [[ $1 == '--shutdown' ]]; then
        systemctl poweroff
    elif [[ $1 == '--lock' ]]; then
        hyprctl dispatch exit
    elif [[ $1 == '--reboot' ]]; then
        systemctl reboot
    elif [[ $1 == '--suspend' ]]; then
        mpc -q pause
        amixer set Master mute
        systemctl suspend
    elif [[ $1 == '--logout' ]]; then
        if [[ "$DESKTOP_SESSION" == 'openbox' ]]; then
            openbox --exit
        elif [[ "$DESKTOP_SESSION" == 'bspwm' ]]; then
            bspc quit
        elif [[ "$DESKTOP_SESSION" == 'i3' ]]; then
            i3-msg exit
        elif [[ "$DESKTOP_SESSION" == 'plasma' ]]; then
            qdbus org.kde.ksmserver /KSMServer logout 0 0 0
        fi
    fi
}

# Actions
chosen="$(run_rofi)"
case "${chosen}" in
    "$shutdown")
        run_cmd --shutdown
        ;;
    "$reboot")
        run_cmd --reboot
        ;;
    "$lock")
        run_cmd --lock
		;;
    "$suspend")
        run_cmd --suspend
        ;;
    "$logout")
        run_cmd --logout
        ;;
esac
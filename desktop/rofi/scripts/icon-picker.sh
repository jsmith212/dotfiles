#!/bin/bash

ICON_FILE="$HOME/.config/rofi/scripts/icons.txt"

[ ! -f "$ICON_FILE" ] && exit 1

choice=$(cat "$ICON_FILE" | rofi -dmenu -i -p "Nerd Icon")

[ -z "$choice" ] && exit

icon=$(echo "$choice" | awk '{print $1}')

echo -n "$icon" | wl-copy
notify-send "Icon Copied" "$icon"

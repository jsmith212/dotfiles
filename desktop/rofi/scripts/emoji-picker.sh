#!/bin/bash

EMOJI_FILE="$HOME/.config/rofi/scripts/emojis.txt"

[ ! -f "$EMOJI_FILE" ] && exit 1

choice=$(cat "$EMOJI_FILE" | rofi -dmenu -i -p "Emoji")

[ -z "$choice" ] && exit

emoji=$(echo "$choice" | awk '{print $1}')

echo -n "$emoji" | wl-copy
notify-send "Emoji Copied" "$emoji"

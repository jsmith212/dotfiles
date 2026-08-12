#!/usr/bin/env bash

COLOR=$(hyprpicker)

[ -z "$COLOR" ] && exit 0

printf " %s" "$COLOR" | wl-copy

notify-send " 󰃉 Color Copied"  "   $COLOR"

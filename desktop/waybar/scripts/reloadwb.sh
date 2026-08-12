#!/bin/bash

pkill -x waybar 
pkill -x swaync 
pkill -x swayosd-server
waybar &
swaync &
swayosd-server &

(
    sleep 0.9
    notify-send "󰑓 Reload Complete" "Waybar and SwayNC"
) &

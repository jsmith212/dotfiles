#!/bin/bash

USER=$(whoami)
HOST=${HOSTNAME:-$(uname -n)}
UPTIME=$(uptime | sed 's/up //')
KERNEL=$(uname -r)
RAM=$(free -h | awk '/Mem:/ {print $3 "/" $2}')

MENU=$(cat << EOF
 $USER
 Hyprland • NixOS@$HOST
󱐿 Uptime: $UPTIME
󰆼 Kernel: $KERNEL
 RAM: $RAM
󰌍 Back
EOF
)

choice=$(echo "$MENU" | rofi -dmenu -i -p "Scripts")

~/.config/rofi/scripts/menu.sh

#!/bin/bash

CURRENT_WALL="$HOME/.cache/current_wp"

# awww wallpaper
awww img "$CURRENT_WALL"

# Waybar reload
pkill waybar
waybar &

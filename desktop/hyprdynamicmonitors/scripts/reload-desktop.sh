#!/bin/bash

CURRENT_WALL="$HOME/.cache/current_wp"

# SWWW wallpaper
swww img "$CURRENT_WALL"

# Waybar reload
pkill waybar
waybar &

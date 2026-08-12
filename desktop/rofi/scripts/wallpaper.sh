#!/bin/bash

# =========================
# Paths
# =========================
WALL_DIR="$HOME/Wallpapers"
CACHE="$HOME/.cache/rofi-wallpapers"
CURRENT_WALL="$HOME/.cache/current_wallpaper"
CURRENT_WALLGIF="$HOME/.cache/current_wp"

mkdir -p "$CACHE"

# =========================
# Generate thumbnails (static only)
# =========================
for img in "$WALL_DIR"/*.{jpg,jpeg,png,webp}; do
    [ -e "$img" ] || continue

    base="$(basename "$img")"
    thumb="$CACHE/$base.png"

    if [ ! -f "$thumb" ]; then
        magick "$img" -resize 200x200 -quality 40 "$thumb"
    fi
done

# =========================
# Rofi menu (static + GIF)
# =========================
choice=$((
    for img in "$WALL_DIR"/*.{jpg,jpeg,png,webp}; do
        [ -e "$img" ] || continue
        base="$(basename "$img")"
        echo -e "$base\x00icon\x1f$CACHE/$base.png"
    done

    for img in "$WALL_DIR"/*.gif; do
        [ -e "$img" ] || continue
        basename "$img"
    done
) | rofi -dmenu \
        -theme ~/.config/rofi/wallpaper.rasi \
        -p "Wallpaper")

[ -z "$choice" ] && exit

IMG_PATH="$WALL_DIR/$choice"
IMG_NAME="${choice%.*}"

# =========================
# Random grow position
# =========================

RANDOM_POS="$(awk 'BEGIN {
    srand();
    printf "%.2f,%.2f", rand(), rand()
}')"

# =========================
# Wallpaper change (SINGLE GROW)
# =========================
awww img "$IMG_PATH" \
    --transition-type random \
    --transition-pos "$RANDOM_POS" \
    --transition-duration 2.8 \
    --transition-fps 60

# =========================
# Notify
# =========================

(
    sleep 1.8
    notify-send -i "$IMG_PATH" "Wallpaper Changed" "$IMG_NAME"
) &

# =========================
# Wallpaper cache (Hyprlock-safe)
# =========================
# Only update hyprlock cache for non-GIF wallpapers
if [[ "$IMG_PATH" != *.gif ]]; then
    ln -sf "$IMG_PATH" "$CURRENT_WALL"
fi

ln -sf "$IMG_PATH" "$CURRENT_WALLGIF"

# Restart hyprlock if running
pkill hyprlock 2>/dev/null

# =========================
# Matugen
# =========================
matugen image "$IMG_PATH"

# =========================
# Safe reloads
# =========================

# Reload waybar CSS only
pkill -USR2 waybar

# Close rofi cleanly
pkill rofi

# Restart SwayNC cleanly
(
    sleep 1
    pkill swaync
    swaync &
) &

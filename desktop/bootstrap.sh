#!/usr/bin/env bash
# Seed the generated files that Hyprland needs at startup.
#
# hyprland.conf does `source = colors.conf` and `source = monitors.conf`, but
# both are produced by tools that only run *after* the session is up (matugen
# from the wallpaper, hyprdynamicmonitors from the attached displays). They are
# build artifacts, so they are gitignored -- which means on a fresh machine they
# don't exist yet and the first launch would source two missing files.
#
# This script creates them. It is idempotent and safe to re-run.
#
# Usage: ./bootstrap.sh [wallpaper]
# With no argument it reuses the current wallpaper, falling back to the default.

set -euo pipefail

DEFAULT_WALLPAPER="$HOME/Wallpapers/grove.jpg"
CURRENT_WALL="$HOME/.cache/current_wallpaper"
CURRENT_WALLGIF="$HOME/.cache/current_wp"
HYPR_DIR="$HOME/.config/hypr"
HDM_DIR="$HOME/.config/hyprdynamicmonitors"

# ---------------------------------------------------------------------------
# Monitors: seed from the fallback profile until hyprdynamicmonitors picks the
# real one based on what's actually plugged in.
# ---------------------------------------------------------------------------
if [ ! -e "$HYPR_DIR/monitors.conf" ]; then
    cp "$HDM_DIR/hyprconfigs/fallback.conf" "$HYPR_DIR/monitors.conf"
    echo "bootstrap: seeded monitors.conf from the fallback profile"
fi

# ---------------------------------------------------------------------------
# Colours: regenerate the whole matugen palette from the wallpaper.
# See desktop/matugen/config.toml for everything this writes.
# ---------------------------------------------------------------------------
if [ $# -ge 1 ]; then
    IMG_PATH="$1"
elif [ -e "$CURRENT_WALL" ]; then
    IMG_PATH="$(readlink -f "$CURRENT_WALL")"
else
    IMG_PATH="$DEFAULT_WALLPAPER"
fi

if [ ! -f "$IMG_PATH" ]; then
    echo "bootstrap: wallpaper not found: $IMG_PATH" >&2
    exit 1
fi

# hyprlock reads the wallpaper through this cache symlink.
mkdir -p "$HOME/.cache"
ln -sfn "$IMG_PATH" "$CURRENT_WALL"
ln -sfn "$IMG_PATH" "$CURRENT_WALLGIF"

# matugen's post_hooks reload the live session (hyprctl, waybar, tmux). On a
# fresh machine none of those are running, so don't let a failed hook abort us.
matugen image "$IMG_PATH" || true

echo "bootstrap: generated colours from $(basename "$IMG_PATH")"

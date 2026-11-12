#!/usr/bin/env bash
# Seed the generated files that Hyprland needs at startup.
#
# hyprland.lua does `require("colors")` and `require("monitors")`, but
# both are produced by tools that only run *after* the session is up (matugen
# from the wallpaper, hyprdynamicmonitors from the attached displays). They are
# build artifacts, so they are gitignored -- which means on a fresh machine they
# don't exist yet and the first launch would fall back to a built-in palette and a generic monitor rule.
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
if [ ! -e "$HYPR_DIR/monitors.lua" ]; then
    cp "$HDM_DIR/hyprconfigs/fallback.lua" "$HYPR_DIR/monitors.lua"
    echo "bootstrap: seeded monitors.lua from the fallback profile"
fi

# ---------------------------------------------------------------------------
# GTK settings: dark colour scheme, icon theme, fonts. dconf is a binary
# database, so it can't be symlinked -- load a text dump instead. `dconf load`
# merges: keys not listed in the dump are left alone.
# ---------------------------------------------------------------------------
DOTFILES_DESKTOP="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
if command -v dconf >/dev/null 2>&1; then
    if dconf load / < "$DOTFILES_DESKTOP/dconf/settings.ini"; then
        echo "bootstrap: loaded dconf settings"
    else
        echo "bootstrap: dconf load failed (no session bus yet?), re-run after login" >&2
    fi
fi

# ---------------------------------------------------------------------------
# Thunar: open in the list ("details", Ctrl+2) view. Thunar keeps its settings
# in xfconf, which rewrites this file, so seed a copy rather than symlink it.
# Needs programs.xfconf.enable in the NixOS config or Thunar forgets everything.
# ---------------------------------------------------------------------------
XFCONF_DIR="$HOME/.config/xfce4/xfconf/xfce-perchannel-xml"
if [ ! -e "$XFCONF_DIR/thunar.xml" ]; then
    mkdir -p "$XFCONF_DIR"
    cp "$DOTFILES_DESKTOP/thunar/thunar.xml" "$XFCONF_DIR/thunar.xml"
    echo "bootstrap: seeded Thunar settings (list view)"
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

# --source-color-index 0 picks the most dominant colour without asking. Since
# matugen 4.0 an image with several candidate source colours opens an
# interactive prompt, which fails outright when there's no terminal attached.
#
# matugen's post_hooks also reload the live session (hyprctl, waybar, tmux). On
# a fresh machine none of those are running, so don't let a failed hook abort us.
matugen image "$IMG_PATH" --source-color-index 0 || true

echo "bootstrap: generated colours from $(basename "$IMG_PATH")"

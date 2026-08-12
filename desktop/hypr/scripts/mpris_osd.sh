#!/bin/bash

# -------------------------------------------------
# MPRIS Media OSD (Hyprland + SwayNC)
# -------------------------------------------------

# ---------------- CONFIG ----------------
ACTION="$1"
SYNC_ID="mpris"
CACHE_DIR="$HOME/.cache/mpris-art"
ART_FILE="$CACHE_DIR/cover.jpg"
MAX_CHARS=24
# ----------------------------------------

mkdir -p "$CACHE_DIR"

# ---------------- STATE (UX-FIRST) ----------------
OLD_STATUS=$(playerctl status 2>/dev/null)

case "$ACTION" in
  play-pause)
    if [ "$OLD_STATUS" = "Playing" ]; then
      STATE="Paused"
    else
      STATE="Playing"
    fi
    playerctl play-pause
    ;;
  next)
    STATE="Playing"
    playerctl next
    ;;
  prev)
    STATE="Playing"
    playerctl previous
    ;;
  *)
    STATE="$OLD_STATUS"
    ;;
esac
# --------------------------------------------------

# Small delay for metadata refresh (non-blocking UX)
sleep 0.1

# ---------------- METADATA ----------------
TITLE=$(playerctl metadata title 2>/dev/null)
ARTIST=$(playerctl metadata artist 2>/dev/null)
ALBUM=$(playerctl metadata album 2>/dev/null)
ART_URL=$(playerctl metadata mpris:artUrl 2>/dev/null)

[ -z "$TITLE" ] && exit 0
# --------------------------------------------------

# ---------------- BODY (ONE LINE ONLY) ----------------
BASE="$ARTIST"
[ -n "$ALBUM" ] && BASE="$ARTIST — $ALBUM"

SUFFIX=" • $STATE"
MAX_BASE_LEN=$((MAX_CHARS - ${#SUFFIX}))

if [ "${#BASE}" -gt "$MAX_BASE_LEN" ]; then
  BASE="${BASE:0:$((MAX_BASE_LEN - 1))}…"
fi

BODY="$BASE$SUFFIX"
# -----------------------------------------------------

# ---------------- ALBUM ART ----------------
ART_PATH=""

if [[ "$ART_URL" == file://* ]]; then
  ART_PATH="${ART_URL#file://}"

elif [[ "$ART_URL" == http* ]] && command -v curl >/dev/null; then
  curl -sL "$ART_URL" -o "$ART_FILE"
  ART_PATH="$ART_FILE"
fi
# -----------------------------------------------------

# ---------------- NOTIFICATION ----------------
notify-send \
  -u low \
  -h string:x-canonical-private-synchronous:"$SYNC_ID" \
  ${ART_PATH:+-h string:image-path:"$ART_PATH"} \
  "$TITLE" \
  "$BODY"
# -----------------------------------------------------

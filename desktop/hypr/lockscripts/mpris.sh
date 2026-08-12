#!/bin/bash

export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
PLAYERCTL="/usr/bin/playerctl"

[ ! -x "$PLAYERCTL" ] && exit 0

STATUS="$($PLAYERCTL status 2>/dev/null)"
[ "$STATUS" != "Playing" ] && exit 0

PLAYER="$($PLAYERCTL metadata --format '{{playerName}}' 2>/dev/null | tr '[:upper:]' '[:lower:]')"
ARTIST="$($PLAYERCTL metadata artist 2>/dev/null)"
TITLE="$($PLAYERCTL metadata title 2>/dev/null)"

[ -z "$ARTIST" ] && ARTIST="Unknown"
[ -z "$TITLE" ] && TITLE="Unknown"

# icons
ICON=""
case "$PLAYER" in
    spotify)   ICON="" ;;
    mpd)       ICON="󰎆" ;;
    firefox*)  ICON="" ;;
    chromium*) ICON="" ;;
    vlc)       ICON="󰕼" ;;
    mpv)       ICON="" ;;
esac

LINE="$ICON  $ARTIST — $TITLE"

# ---------- truncate with ellipsis ----------
MAX=44
if [ "${#LINE}" -gt "$MAX" ]; then
    LINE="${LINE:0:$((MAX-1))}…"
fi

# ---------- progress ----------
POS_SEC="$($PLAYERCTL position 2>/dev/null | cut -d. -f1)"
LEN_MICRO="$($PLAYERCTL metadata mpris:length 2>/dev/null)"

LEN_SEC=$(( LEN_MICRO / 1000000 ))
[ "$LEN_SEC" -le 0 ] && echo "$LINE" && exit 0

BAR_W=18
FILLED=$(( POS_SEC * BAR_W / LEN_SEC ))
EMPTY=$(( BAR_W - FILLED ))

BAR="$(printf '%0.s●' $(seq 1 $FILLED))$(printf '%0.s○' $(seq 1 $EMPTY))"

fmt() { printf "%d:%02d" $(( $1 / 60 )) $(( $1 % 60 )); }

echo "$LINE"
echo "$BAR  $(fmt $POS_SEC) / $(fmt $LEN_SEC)"

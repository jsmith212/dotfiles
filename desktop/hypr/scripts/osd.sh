#!/bin/bash

# -------------------------------------------------
# Volume OSD (Hyprland + SwayNC)
# -------------------------------------------------

# ---------------- CONFIG ----------------
STEP=5
SINK="@DEFAULT_AUDIO_SINK@"
# ----------------------------------------

# ---------------- HELPERS ----------------
get_volume() {
  wpctl get-volume "$SINK" | awk '{print int($2 * 100)}'
}

get_raw_volume() {
  wpctl get-volume "$SINK" | awk '{print $2}'
}

is_muted() {
  wpctl get-volume "$SINK" | grep -q MUTED
}

clamp_volume() {
  RAW=$(get_raw_volume)
  awk "BEGIN { exit !($RAW > 1.0) }" && \
    wpctl set-volume "$SINK" 1.0
}

send_osd() {
  notify-send \
    -u low \
    -h string:x-canonical-private-synchronous:volume \
    -h int:value:"$2" \
    "Volume" \
    "$1"
}
# ----------------------------------------

# ---------------- ACTION ----------------
case "$1" in
  up)
    wpctl set-volume "$SINK" ${STEP}%+
    ;;
  down)
    wpctl set-volume "$SINK" ${STEP}%-
    ;;
  mute)
    wpctl set-mute "$SINK" toggle
    ;;
esac
# ----------------------------------------

# Allow PipeWire to update state
sleep 0.05

# Enforce 100% max
clamp_volume

# ---------------- OSD ----------------
if is_muted; then
  send_osd "Muted" 0
else
  VOL=$(get_volume)
  send_osd "$VOL%" "$VOL"
fi
# -------------------------------------

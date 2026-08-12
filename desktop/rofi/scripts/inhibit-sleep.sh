#!/bin/bash

if pgrep -x "hypridle" >/dev/null ;then
  pkill -f hypridle
else
  hypridle
fi

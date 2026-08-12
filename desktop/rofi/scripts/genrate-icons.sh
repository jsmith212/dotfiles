#!/bin/bash

jq -r 'to_entries[] | "\(.value.char)  \(.key)"' \
~/.config/rofi/scripts/glyphnames.json \
> ~/.config/rofi/scripts/icons.txt

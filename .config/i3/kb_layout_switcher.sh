#!/bin/bash

LANG_FILE="$HOME/.config/i3/layouts.txt"

mapfile -t options < <(tail -n +2 "$LANG_FILE" | cut -d',' -f1)

selected_index=$(printf "%s\n" "${options[@]}" | rofi -dmenu -p "Select layout" -format i -i)

if [[ "$selected_index" =~ ^[0-9]+$ ]]; then
    layout_code=$(tail -n +2 "$LANG_FILE" | sed -n "$((selected_index + 1))p" | cut -d',' -f2)
    setxkbmap "$layout_code"
fi
#!/bin/bash

options="Reset\n25%\n50%\n75%\n100%"

choice=$(echo -e "$options" | rofi -dmenu -p "Redshift: " -i)

calculate_temp() {
    echo $((6500 - ($1 * 35)))
}

case "$choice" in
    "Reset")
        redshift -x
        exit 0
        ;;
    "25%")
        temp=$(calculate_temp 25)
        ;;
    "50%")
        temp=$(calculate_temp 50)
        ;;
    "75%")
        temp=$(calculate_temp 75)
        ;;
    "100%")
        temp=3000
        ;;
    *)
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 0 ] && [ "$choice" -le 100 ]; then
            temp=$(calculate_temp "$choice")
        else
            exit 1
        fi
        ;;
esac

redshift -P -O $temp

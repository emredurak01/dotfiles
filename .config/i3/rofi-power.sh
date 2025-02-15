#!/bin/bash

options="Shutdown\nReboot\nSuspend\nLogout\nLock"

choice=$(echo -e "$options" | rofi -dmenu -p "Power Menu: " -i)

case "$choice" in
    "Shutdown")
        systemctl poweroff
        ;;
    "Reboot")
        systemctl reboot
        ;;
    "Suspend")
        systemctl suspend
        ;;
    "Logout")
        i3-msg exit        
        ;;
    "Lock")
        sleep 0.1
        ~/.config/i3/lock.sh &
        exit 0
        ;;
    *)
        exit 1
        ;;
esac


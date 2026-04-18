#!/bin/sh
# /usr/local/bin/kiosk-menu.sh
set -eu

start_eq() {
    /usr/local/bin/eQ
}

main_menu() {
    while true; do
        CHOICE=$(whiptail --title "eQ Kiosk Menu" --menu "Choose an action" 16 60 6 \
            "1" "Start eQ" \
            "2" "Create wallet disk" \
            "3" "Remove wallet disk" \
            "4" "Exit and shutdown" 3>&1 1>&2 2>&3) || return 0

        case "$CHOICE" in
            1)
                start_eq
                ;;
            2)
                echo "create_wallet"
                ;;
            3)
                echo "detach_and_remove_wallet"
                ;;
            4)
                systemctl poweroff -i
                ;;
            *)
                whiptail --msgbox "Unknown option" 8 40
                ;;
        esac
    done
}

main_menu

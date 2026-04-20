#!/bin/sh
# /usr/local/bin/kiosk-menu.sh
set -eu

# ≡≡≡≡≡≡≡ Draw terminal ≡≡≡≡≡≡≡
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
draw_terminal() {
    TEXT="$1"
    WIDTH=$(tput cols)

    BORDER="+";
    SPACE="-";
    VERTICAL="|"

    # Calculate padding
    TEXT_LEN=${#TEXT}
    INNER_WIDTH=$((WIDTH - 2))
    PAD=$(((INNER_WIDTH - TEXT_LEN) / 2))
    PAD_RIGHT=$((INNER_WIDTH - TEXT_LEN - PAD))

    # Top border
    printf "%s" "$BORDER"
    printf "%${INNER_WIDTH}s" | tr " " "$SPACE"
    printf "%s\n" "$BORDER"

    # Middle line
    printf "%s%*s%s%*s%s\n" "$VERTICAL" "$PAD" "" "$TEXT" "$PAD_RIGHT" "" "$VERTICAL"

    # Bottom border
    printf "%s" "$BORDER"
    printf "%${INNER_WIDTH}s" | tr " " "$SPACE"
    printf "%s\n" "$BORDER"
}


# ≡≡≡≡≡≡≡ Get build data ≡≡≡≡≡≡≡
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
get_build_data() {
    if [ -f "/home/eqos/VERSION" ]; then
    VER=$(cat /home/eqos/VERSION)
    else
    VER="Not Found"
    fi

    if [ -f "/home/eqos/BUILD" ]; then
    BUILD=$(cat /home/eqos/BUILD)
    else
    BUILD="Not Found"
    fi

    echo "Version:       $VER"
    echo "Build date:    $BUILD"
    echo
}


# ≡≡≡≡≡≡≡ Start eQ ≡≡≡≡≡≡≡
# ━━━━━━━━━━━━━━━━━━━━━━━━
start_eq() {
    if [ ! -f /usr/local/bin/eQ ]; then
        echo "eQ not found"
        echo "Exiting..."
        sleep 3
        exit 1
    else
        /usr/local/bin/eQ
    fi
}


# ≡≡≡≡≡≡≡ Create main menu ≡≡≡≡≡≡≡
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
call_main_menu() {
    clear
    draw_terminal "eQ-OS - Secure Wallet Environment"
    get_build_data
    draw_terminal "$1"
}


# ≡≡≡≡≡≡≡ Create wallet menu ≡≡≡≡≡≡≡
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
create_wallet_menu() {
    while true; do
        call_main_menu "CREATE WALLET DISK"

        echo "1) Create encrypted and public part"
        echo "2) Create encrypted part only"
        echo "3) Go back"
        echo
        printf "Select option: "

        read SUBCHOICE

        case "$SUBCHOICE" in
            1)
                echo "create_encrypted_and_public"
                read -p "Press Enter to continue..."
                ;;
            2)
                echo "create_encrypted_only"
                read -p "Press Enter to continue..."
                ;;
            3)
                call_main_menu "MAIN MENU"
                return
                ;;
            *)
                echo "Invalid option"
                sleep 1
                ;;
        esac
    done
}


call_main_menu "MAIN MENU"

while true; do
    echo "1) Start eQ"
    echo "2) Create wallet disk"
    echo "3) Remove wallet disk"
    echo "4) Shutdown"
    echo
    printf "Select option: "

    read CHOICE

    case "$CHOICE" in
        1)
            start_eq
            ;;
        2)
            create_wallet_menu
            ;;
        3)
            echo "detach_and_remove_wallet"
            read -p "Press Enter to continue..."
            call_main_menu "MAIN MENU"
            ;;
        4)
            systemctl poweroff -i
            ;;
        *)
            echo "Invalid option"
            sleep 1
            ;;
    esac
done
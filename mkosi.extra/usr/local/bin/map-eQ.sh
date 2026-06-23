#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'
umask 077

readonly TTY="/dev/tty1"
readonly MAPPER_NAME="eQ"
readonly MOUNT_POINT="/eQ"

VERSION="$(< /etc/eQ/eQ-OS.version)"
readonly TITLE="eQ-OS v${VERSION}"

HEIGHT=14
WIDTH=70

export NEWT_COLORS='
root=,black
window=cyan,black
border=cyan,black
textbox=white,black
button=black,cyan
actbutton=black,white
title=white,black
roottext=white,black
entry=white,black
compactbutton=white,black
checkbox=white,black
'

DEVICE=""
PASS1=""
PASS2=""
OLD_PASS=""

cleanup() {
    unset PASS1 PASS2 VERSION DEVICE
    clear
}

trap cleanup EXIT HUP INT TERM

exec <"$TTY" >"$TTY" 2>&1
clear

msgbox() {
    whiptail \
        --title "$TITLE" \
        --msgbox \
        "$1" \
        "$HEIGHT" "$WIDTH"
}

infobox() {
    whiptail \
        --title "$TITLE" \
        --infobox \
        "$1" \
        "$HEIGHT" "$WIDTH"
}

yesno() {
    whiptail \
        --title "$TITLE" \
        --yesno \
        "$1" \
        "$HEIGHT" "$WIDTH"
}

passwordbox() {
    whiptail \
        --title "$TITLE" \
        --passwordbox \
        "$1" \
        "$HEIGHT" "$WIDTH" \
        3>&1 1>&2 2>&3
}

find_eq_device() {
    DEVICE="$(blkid -t PARTLABEL=eQ -o device 2>/dev/null | head -n1 || true)"
    
    if [[ -z "$DEVICE" ]]; then
        DEVICE="$(blkid -t LABEL=eQ -o device 2>/dev/null | head -n1 || true)"
    fi

    if [[ -z "$DEVICE" ]]; then
        msgbox "FATAL ERROR: No 'eQ' partition found.\n\nCannot continue."
        exit 1
    fi
}

format_eq_ext4() {
    local mapper="/dev/mapper/${MAPPER_NAME}"

    if findmnt -rno TARGET "$mapper" >/dev/null 2>&1; then
        local target
        target="$(findmnt -rno TARGET "$mapper")"

        if ! umount -f "$target"; then
            msgbox "ERROR: Cannot unmount $target before formatting."
            return 1
        fi
    fi

    if ! mkfs.ext4 -F -v "$mapper"; then
        msgbox "ERROR: Failed to create filesystem on encrypted storage."
        return 1
    fi

    return 0
}

set_eq_permissions() {
    if ! chown eqos:eqos "$MOUNT_POINT"; then
        msgbox "ERROR: Failed to set ownership on eQ storage."
        return 1
    fi

    if ! chmod 700 "$MOUNT_POINT"; then
        msgbox "ERROR: Failed to set permissions on eQ storage."
        return 1
    fi

    return 0
}

mount_eq_storage() {
    local mapper="/dev/mapper/${MAPPER_NAME}"

    if [[ ! -b "$mapper" ]]; then
        msgbox "ERROR: Encrypted mapper device not found."
        return 1
    fi

    mkdir -p "$MOUNT_POINT"

    if ! findmnt -rno TARGET "$mapper" >/dev/null 2>&1; then
        local fstype
        fstype="$(blkid -o value -s TYPE "$mapper" 2>/dev/null || true)"

        if [[ -z "$fstype" ]]; then
            if ! format_eq_ext4; then
                return 1
            fi
        fi

        if ! mount -o noatime "$mapper" "$MOUNT_POINT"; then
            msgbox "ERROR: Failed to mount eQ storage."
            return 1
        fi
    fi

    if ! set_eq_permissions; then
        return 1
    fi

    return 0
}

unlock_luks() {
    while true; do
        PASS1="$(passwordbox "\nEnter your master password to unlock eQ-OS:")"
        [[ -z "${PASS1:-}" ]] && continue

        if printf '%s' "$PASS1" | cryptsetup open \
            --type luks2 \
            --key-file=- \
            --tries=2 \
            "$DEVICE" "$MAPPER_NAME" 2>/dev/null; then
            unset PASS1
            if mount_eq_storage; then
                return 0
            fi
            msgbox "ERROR: Failed to prepare eQ storage after unlock."
            exit 10
        fi

        unset PASS1
        if ! yesno "Incorrect password.\n\nTry again?"; then
            msgbox "Too many failed attempts.\nExiting."
            exit 99
        fi
    done
}

change_master_password() {
    infobox "Master Password Change\n\nYou need the current password first."

    OLD_PASS="$(passwordbox "\nEnter CURRENT master password:")"
    [[ -z "${OLD_PASS:-}" ]] && return 1

    if ! printf '%s' "$OLD_PASS" | cryptsetup open --test-passphrase --key-file=- "$DEVICE" 2>/dev/null; then
        msgbox "ERROR: Current password is incorrect."
        return 1
    fi

    while true; do
        PASS1="$(passwordbox "\nEnter NEW master password:")"
        [[ -z "${PASS1:-}" ]] && {
            msgbox "Password cannot be empty."
            continue
        }

        PASS2="$(passwordbox "Confirm NEW master password:")"

        if [[ "$PASS1" != "$PASS2" ]]; then
            unset PASS1 PASS2
            msgbox "Passwords do not match.\nPlease try again."
            continue
        fi
        break
    done

    infobox "Changing master password...\nThis may take a few seconds."

    if printf '%s\n%s' "$OLD_PASS" "$PASS1" | cryptsetup luksChangeKey \
        --batch-mode \
        --key-file=- \
        "$DEVICE" 2>/dev/null; then
        msgbox "Master password changed successfully!\n\nYou can now use the new password."
        unset OLD_PASS PASS1 PASS2
        return 0
    else
        unset OLD_PASS PASS1 PASS2
        msgbox "ERROR: Failed to change password.\n\nPossible reasons:\n- Wrong current password\n- Device busy\n- I/O error"
        return 1
    fi
}

eq_detected() {
    while true; do
        CHOICE=$(menu "\nEncrypted eQ storage detected" 12 \
            "1" "Unlock & Continue Boot" \
            "2" "Change Master Password" \
            "3" "Cancel / Power Off")

        case "$CHOICE" in
            1)
                unlock_luks
                exit 0
                ;;
            2)
                change_master_password
                ;;
            3|"")
                msgbox "Operation cancelled.\nExiting."
                exit 2
                ;;
            *)
                msgbox "Invalid option."
                ;;
        esac
    done
}

initial_setup() {
    if ! yesno "INITIAL SETUP\n\nWelcome to eQ-OS!\n\nDo you want to continue?"; then
        msgbox "Encryption setup cancelled.\nExit"
        exit 2
    fi

    while true; do
        PASS1="$(passwordbox "MASTER PASSWORD\n\nCreate a strong password.\nPassword protects your wallet storage.\n\nNo recovery possible - keep it safe!")"

        [[ -z "${PASS1:-}" ]] && {
            msgbox "Password cannot be empty."
            continue
        }

        PASS2="$(passwordbox "\nConfirm Master Password:")"

        if [[ "$PASS1" != "$PASS2" ]]; then
            unset PASS1 PASS2
            msgbox "Passwords do not match.\nPlease try again."
            continue
        fi
        break
    done

    infobox "Creating encrypted eQ wallet storage...\nThis may take a few moments.\n\nPlease wait until process is done."

    if ! printf '%s' "$PASS1" | cryptsetup luksFormat \
        --type luks2 \
        --batch-mode \
        --key-file=- \
        "$DEVICE"; then
        unset PASS1
        msgbox "ERROR: Failed to initialize encrypted storage."
        exit 3
    fi

    if ! printf '%s' "$PASS1" | cryptsetup open \
        --type luks2 \
        --key-file=- \
        "$DEVICE" "$MAPPER_NAME"; then
        unset PASS1
        msgbox "ERROR: Failed to open encrypted storage."
        exit 4
    fi

    unset PASS1

    if ! format_eq_ext4; then
        msgbox "ERROR: Failed to format eQ storage."
        exit 5
    fi

    if ! mount_eq_storage; then
        msgbox "ERROR: Failed to mount eQ storage after initial setup."
        exit 6
    fi

    exit 0
}

main() {
    find_eq_device

    if cryptsetup isLuks "$DEVICE"; then
        if cryptsetup status "$MAPPER_NAME" >/dev/null 2>&1; then
            if ! mount_eq_storage; then
                msgbox "ERROR: Failed to prepare eQ storage."
                exit 7
            fi
            exit 0
        fi
        eq_detected
    else
        initial_setup
    fi
}

main

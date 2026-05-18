#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'
umask 077

readonly TTY="/dev/tty1"
readonly MAPPER_NAME="eQ"

VERSION="$(< /etc/eQ/eQ-OS.version)"
readonly TITLE="eQ-OS v${VERSION}"

HEIGHT=14
WIDTH=70

export NEWT_COLORS='
root=,black
window=cyan,#070410
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

DEVICE="$(blkid -t PARTLABEL=eQ -o device 2>/dev/null | head -n1 || true)"
if [[ -z "$DEVICE" ]]; then
    DEVICE="$(blkid -t LABEL=eQ -o device 2>/dev/null | head -n1 || true)"
fi

if [[ -z "$DEVICE" ]]; then
    msgbox "FATAL ERROR: No 'eQ' partition found.\nExit"
    exit 1
fi

if cryptsetup isLuks "$DEVICE"; then
    if cryptsetup status "$MAPPER_NAME" >/dev/null 2>&1; then
        exit 0
    fi

    while true; do
        PASS1="$(passwordbox \
            "\nEnter your master password to unlock the system:")"

        [[ -z "${PASS1:-}" ]] && continue

        if printf '%s' "$PASS1" | cryptsetup open \
            --type luks2 \
            --key-file=- \
            --tries=1 \
            "$DEVICE" \
            "$MAPPER_NAME"; then

            unset PASS1

            exit 0
        fi

        unset PASS1

        msgbox "Incorrect password.\n\nExit"
        exit 99
    done
fi

if ! yesno "INITIAL SETUP \n\n\
Welcome!\n\n\
Initializing secure wallet storage\n\n\
Continue with process?"; then

    msgbox "Encryption setup cancelled.\nExit"
    exit 2
fi

while true; do
    PASS1="$(passwordbox \
"MASTER PASSWORD\n\n\
Please create a secure password for protecting your system.\n\
It will be required next time when you start it again.\n\n\
This password protects everything you have.\n\
Please keep it secure; there is no recovery.")"

    [[ -z "${PASS1:-}" ]] && {
        msgbox "Password cannot be empty."
        continue
    }

    PASS2="$(passwordbox "Confirm Master Password:")"

    if [[ "$PASS1" != "$PASS2" ]]; then
        unset PASS1 PASS2
        msgbox "Passwords do not match.\n\nPlease try again."
        continue
    fi

    unset PASS2
    break
done

infobox "Creating encrypted wallet storage...\n\n\
This may take a few seconds."

if ! printf '%s' "$PASS1" | cryptsetup luksFormat \
    --type luks2 \
    --batch-mode \
    --key-file=- \
    "$DEVICE"; then

    unset PASS1
    msgbox "ERROR: Failed to initialize encrypted storage. Exit"
    exit 3
fi

if ! printf '%s' "$PASS1" | cryptsetup open \
    --type luks2 \
    --key-file=- \
    "$DEVICE" \
    "$MAPPER_NAME"; then

    unset PASS1
    msgbox "ERROR: Failed to unlock encrypted storage. Exit"
    exit 4
fi

unset PASS1

exit 0
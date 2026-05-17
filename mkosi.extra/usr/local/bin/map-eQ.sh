#!/usr/bin/env bash
set -euo pipefail

TTY="/dev/tty1"
MAPPER_NAME="eQ"

exec <"$TTY" >"$TTY" 2>&1

echo
echo "-------------------------------"
echo " eQ-OS partition initialization"
echo "-------------------------------"
echo

# Find partition by PARTLABEL or filesystem LABEL
DEVICE=""

DEVICE="$(blkid -t PARTLABEL=eQ -o device 2>/dev/null | head -n1 || true)"

if [[ -z "$DEVICE" ]]; then
    DEVICE="$(blkid -t LABEL=eQ -o device 2>/dev/null | head -n1 || true)"
fi

if [[ -z "$DEVICE" ]]; then
    echo "No partition labeled 'eQ' found."
    echo "Continuing normal login..."
    sleep 2
    exit 0
fi

echo "Found eQ partition:"
echo "  $DEVICE"
echo

# Check whether already LUKS
if cryptsetup isLuks "$DEVICE"; then
    echo "Partition already encrypted."

    if ! cryptsetup status "$MAPPER_NAME" >/dev/null 2>&1; then
        echo
        echo "Unlock required."
        echo

        while true; do
            if cryptsetup open "$DEVICE" "$MAPPER_NAME"; then
                echo
                echo "Unlocked successfully."
                break
            fi

            echo
            echo "Incorrect password. Try again."
            echo
        done
    fi

    sleep 1
    exit 0
fi

# RAW partition detected
echo "WARNING:"
echo "The partition is NOT encrypted."
echo
echo "ALL DATA ON $DEVICE WILL BE DESTROYED."
echo

while true; do
    read -rp "Encrypt partition now? (YES/no): " ANSWER

    case "$ANSWER" in
        YES|yes|y|Y|"")
            break
            ;;
        no|NO|n|N)
            echo "Skipping encryption."
            sleep 2
            exit 0
            ;;
        *)
            echo "Please answer YES or no."
            ;;
    esac
done

echo
echo "Enter new LUKS password."
echo

while true; do
    read -rsp "Password: " PASS1
    echo

    read -rsp "Confirm Password: " PASS2
    echo

    if [[ -z "$PASS1" ]]; then
        echo "Password cannot be empty."
        continue
    fi

    if [[ "$PASS1" != "$PASS2" ]]; then
        echo "Passwords do not match."
        continue
    fi

    break
done

echo
echo "Creating LUKS2 container..."
echo

TMPKEY="$(mktemp)"
trap 'rm -f "$TMPKEY"' EXIT

printf "%s" "$PASS1" > "$TMPKEY"

unset PASS1
unset PASS2

cryptsetup luksFormat \
    --type luks2 \
    --batch-mode \
    "$DEVICE" \
    "$TMPKEY"

echo
echo "Opening encrypted container..."
echo

cryptsetup open \
    "$DEVICE" \
    "$MAPPER_NAME" \
    --key-file "$TMPKEY"

echo
echo "LUKS encryption completed successfully."
echo
echo "Mapped device:"
echo "  /dev/mapper/$MAPPER_NAME"
echo

sleep 2
exit 0
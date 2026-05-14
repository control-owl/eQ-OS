#!/bin/sh
. /lib/dracut-lib.sh

STATE_LABEL="${EQSTATE_LABEL:-eQ}"
CRYPT_NAME="eQ"
MOUNTPOINT="${EQSTATE_MOUNT:-/eQ}"

DEVICE=$(blkid -L "$STATE_LABEL" -o device 2>/dev/null || true)
[ -z "$DEVICE" ] && return 0

if cryptsetup isLuks "$DEVICE" 2>/dev/null; then
    return 0
fi

info "=== eQ-OS FIRST BOOT: Initializing encrypted state ==="

while true; do
    PASS1=$(systemd-ask-password --timeout=0 "Enter new eQ passphrase:" --echo=no)
    PASS2=$(systemd-ask-password --timeout=0 "Confirm passphrase:" --echo=no)
    [ "$PASS1" = "$PASS2" ] && [ -n "$PASS1" ] && break
    warn "Passphrases do not match!"
done

printf "%s" "$PASS1" | cryptsetup luksFormat --type luks2 --pbkdf argon2id \
    --iter-time 5000 --pbkdf-memory 1048576 --pbkdf-parallel 4 \
    --label "${STATE_LABEL}-crypt" "$DEVICE" -

printf "%s" "$PASS1" | cryptsetup open "$DEVICE" "$CRYPT_NAME" -
unset PASS1 PASS2

mkfs.ext4 -L "$STATE_LABEL" "/dev/mapper/$CRYPT_NAME"

mkdir -p "$MOUNTPOINT"
mount "/dev/mapper/$CRYPT_NAME" "$MOUNTPOINT"
mkdir -p "$MOUNTPOINT/wallet" "$MOUNTPOINT/update"
touch "$MOUNTPOINT/.initialized"
umount "$MOUNTPOINT"
cryptsetup close "$CRYPT_NAME"

info "eQ state initialized. Rebooting..."
sleep 2
reboot -f
#!/bin/sh

. /lib/dracut-lib.sh

[ -n "$EQSTATE_SKIP" ] && exit 0

STATE_LABEL="${EQSTATE_LABEL:-eQ}"
CRYPT_NAME="eQ"

for i in $(seq 1 30); do
    DEVICE="/dev/disk/by-label/$STATE_LABEL"
    [ -e "$DEVICE" ] && break
    sleep 1
done

[ ! -e "$DEVICE" ] && exit 0

if cryptsetup isLuks "$DEVICE" 2>/dev/null; then
    exit 0
fi

if [ -e /run/eqstate.done ]; then
    exit 0
fi

touch /run/eqstate.done

info "=== eQ FIRST BOOT INITIALIZATION ==="

while true; do
    PASS1=$(systemd-ask-password "Enter new eQ passphrase:")
    PASS2=$(systemd-ask-password "Confirm passphrase:")

    [ "$PASS1" = "$PASS2" ] && [ -n "$PASS1" ] && break

    warn "Passwords do not match"
done

printf "%s" "$PASS1" | cryptsetup luksFormat \
    --batch-mode \
    --type luks2 \
    "$DEVICE" -

printf "%s" "$PASS1" | cryptsetup open "$DEVICE" "$CRYPT_NAME" -

unset PASS1 PASS2

mkfs.ext4 "/dev/mapper/$CRYPT_NAME"

cryptsetup close "$CRYPT_NAME"

info "Initialization complete. Rebooting."
sleep 3
reboot -f
#!/bin/sh

. /lib/dracut-lib.sh

STATE_LABEL="${EQSTATE_LABEL:-eQ}"
CRYPT_NAME="eQ"
MOUNTPOINT="${EQSTATE_MOUNT:-/eQ}"

DEVICE="/dev/disk/by-label/$STATE_LABEL"

[ -z "$DEVICE" ] && exit 0

cryptsetup isLuks "$DEVICE" || exit 0

if ! cryptsetup status "$CRYPT_NAME" >/dev/null 2>&1; then
    info "Unlocking eQ partition"

    cryptsetup open "$DEVICE" "$CRYPT_NAME" || emergency_shell
fi

mkdir -p "$MOUNTPOINT"

mount "/dev/mapper/$CRYPT_NAME" "$MOUNTPOINT"
#!/bin/sh
. /lib/dracut-lib.sh

STATE_LABEL="${EQSTATE_LABEL:-eQ}"
CRYPT_NAME="eQ"
MOUNTPOINT="${EQSTATE_MOUNT:-/eQ}"

DEVICE=$(blkid -L "$STATE_LABEL" -o device 2>/dev/null || true)
[ -z "$DEVICE" ] && return 0

if ! cryptsetup isLuks "$DEVICE" 2>/dev/null; then
    return 0
fi

if ! cryptsetup status "$CRYPT_NAME" >/dev/null 2>&1; then
    info "eQ-OS: Unlocking state partition..."
    if ! cryptsetup open "$DEVICE" "$CRYPT_NAME"; then
        warn "Failed to unlock eQ partition!"
        systemctl emergency
    fi
fi

mkdir -p "$MOUNTPOINT"
mount "/dev/mapper/$CRYPT_NAME" "$MOUNTPOINT" || warn "eQ mount failed"
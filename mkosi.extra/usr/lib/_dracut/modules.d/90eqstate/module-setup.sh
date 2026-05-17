#!/bin/bash

check() {
    return 0
}

depends() {
    echo "crypt systemd"
    return 0
}

install() {
    inst_multiple \
        blkid \
        cryptsetup \
        mkfs.ext4 \
        systemd-ask-password \
        mount \
        umount \
        reboot

    inst_hook cmdline 20 "$moddir/parse-eqstate.sh"

    inst_hook initqueue/settled 35 "$moddir/eqstate-init.sh"

    inst_hook pre-mount 90 "$moddir/eqstate-mount.sh"
}
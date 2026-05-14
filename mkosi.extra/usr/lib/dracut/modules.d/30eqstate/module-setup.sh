#!/bin/bash
check() { return 0; }

depends() {
    echo "crypt plymouth"
    return 0
}

install() {
    inst_multiple -o blkid cryptsetup mkfs.ext4 systemd-ask-password

    inst_hook cmdline   25 "$moddir/parse-eqstate.sh"
    inst_hook pre-mount 35 "$moddir/eqstate-init.sh"
    inst_hook mount     75 "$moddir/eqstate-mount.sh"

    inst_simple "$moddir/eqstate-init.sh"  "/sbin/eqstate-init.sh"
    inst_simple "$moddir/eqstate-mount.sh" "/sbin/eqstate-mount.sh"
}
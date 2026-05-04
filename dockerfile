FROM archlinux:latest

RUN pacman -Sy --noconfirm \
    mkosi \
    systemd \
    systemd-nspawn \
    debootstrap \
    squashfs-tools \
    dosfstools \
    parted \
    e2fsprogs \
    qemu-img \
    mtools \
    gpg

WORKDIR /workspace
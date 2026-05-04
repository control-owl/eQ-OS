FROM archlinux:latest

RUN pacman -Sy --noconfirm \
    mkosi \
    systemd \
    debootstrap \
    squashfs-tools \
    dosfstools \
    parted \
    qemu-img \
    mtools

WORKDIR /workspace
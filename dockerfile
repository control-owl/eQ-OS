FROM archlinux:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN pacman -Sy --noconfirm \
    mkosi \
    systemd \
    debootstrap \
    squashfs-tools \
    dosfstools \
    parted \
    qemu-img \
    mtools

COPY . /workspace-src

WORKDIR /workspace

RUN mkdir -p /workspace/.mkosi-cache \
    /workspace/.mkosi.builddir \
    /workspace/.mkosi.tools \
    /workspace/.ISO

CMD ["/bin/bash"]
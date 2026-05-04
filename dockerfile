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
    debian-archive-keyring \
    apt \
    diffutils \
    mtools

COPY . /workspace

WORKDIR /workspace

RUN mkdir -p \
    /workspace/.mkosi.builddir \
    /workspace/.mkosi-cache \
    /workspace/.mkosi.cache \
    /workspace/.mkosi.tools \
    /workspace/.ISO

CMD ["/bin/bash"]
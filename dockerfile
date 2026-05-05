FROM archlinux:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN pacman -Syu --noconfirm

RUN pacman -Sy --noconfirm \
    mkosi \
    systemd \
    debootstrap \
    squashfs-tools \
    dosfstools \
    parted \
    e2fsprogs \
    debian-archive-keyring \
    qemu-img \
    mtools \
    gnupg \
    git \
    diffutils \
    cpio

COPY . /workspace

WORKDIR /workspace

RUN mkdir -p \
    /workspace/mkosi.builddir \
    /workspace/mkosi.cache \
    /workspace/buildcache \
    /workspace/ISO \
    /var/tmp/mkosi-tmp \
    /work

CMD ["/bin/bash"]

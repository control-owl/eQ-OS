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
    qemu-img \
    mtools \
    gnupg \
    git \
    diffutils \
    cpio

COPY . /workspace-src

WORKDIR /workspace

RUN mkdir -p \
    /workspace/mkosi.builddir \
    /workspace/mkosi.cache \
    /workspace/buildcache \
    /workspace/ISO \
    /var/tmp/mkosi-tmp \
    /work

RUN chmod 1777 /workspace /var/tmp/mkosi-tmp /work

RUN chown -R root:root /workspace /var/tmp/mkosi-tmp /work

CMD ["/bin/bash"]

#!/usr/bin/env bash
set -euo pipefail

# ≡≡≡≡≡≡≡≡≡ Prepare qemu firmware ≡≡≡≡≡≡≡≡≡
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

QEMU_DIR="qemu"
OUTPUT_DIR="ISO"
IMAGE="eQ-OS.raw"
OVMF_CODE="/usr/share/edk2/x64/OVMF_CODE.4m.fd"
OVMF_VARS_SRC="/usr/share/edk2/x64/OVMF_VARS.4m.fd"
OVMF_VARS_LOCAL="$QEMU_DIR/OVMF_VARS.fd"
mkdir -p "$QEMU_DIR"
cp "$OVMF_VARS_SRC" "$OVMF_VARS_LOCAL"


# ≡≡≡≡≡≡≡≡≡  boot system in qemu  ≡≡≡≡≡≡≡≡≡
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo "Starting QEMU..."
qemu-system-x86_64 \
    -m 2048 \
    -enable-kvm \
    -cpu host \
    -drive if=pflash,format=raw,readonly=on,file="$OVMF_CODE" \
    -drive if=pflash,format=raw,file="$OVMF_VARS_LOCAL" \
    -drive file="$OUTPUT_DIR/$IMAGE",format=raw,if=virtio \
    -vga virtio \
    -display gtk,gl=off,show-cursor=on \
    -serial mon:stdio
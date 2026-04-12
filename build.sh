#!/usr/bin/env bash
set -euo pipefail

# Create log directory and timestamped log file
LOG_DIR="log"
mkdir -p "$LOG_DIR"
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
LOG_FILE="${LOG_DIR}/build-output-${TIMESTAMP}.log"

# Log everything from now on
exec > >(tee -a "$LOG_FILE") 2>&1

echo "===== Build started at $(date) ====="
echo "Log file: $LOG_FILE"

export PATH="$PATH:/usr/bin:/sbin:/usr/sbin"

IMAGE="eQ-OS.raw"
OUTPUT_DIR="ISO"
QEMU_DIR="qemu"

mkosi clean
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

echo "Running mkosi build..."
mkosi build

if [ ! -f "$OUTPUT_DIR/$IMAGE" ]; then
    echo "ERROR: Image not created!"
    exit 1
fi

echo "Image built successfully: $OUTPUT_DIR/$IMAGE"

# Prepare OVMF for QEMU
OVMF_CODE="/usr/share/edk2/x64/OVMF_CODE.4m.fd"
OVMF_VARS_SRC="/usr/share/edk2/x64/OVMF_VARS.4m.fd"
OVMF_VARS_LOCAL="$QEMU_DIR/OVMF_VARS.fd"

mkdir -p "$QEMU_DIR"
cp "$OVMF_VARS_SRC" "$OVMF_VARS_LOCAL"

echo "Starting QEMU..."
qemu-system-x86_64 \
    -m 2048 \
    -enable-kvm \
    -cpu host \
    -machine q35 \
    -drive if=pflash,format=raw,readonly=on,file="$OVMF_CODE" \
    -drive if=pflash,format=raw,file="$OVMF_VARS_LOCAL" \
    -drive file="$OUTPUT_DIR/$IMAGE",format=raw,if=virtio \
    -device virtio-gpu-pci \
    -display gtk,gl=off,show-cursor=on \
    -serial mon:stdio \
    -vga std

echo "===== Build & boot finished at $(date) ====="
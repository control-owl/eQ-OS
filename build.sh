#!/usr/bin/env bash
set -euo pipefail


# ≡≡≡≡≡≡≡≡≡ Initialize logging ≡≡≡≡≡≡≡≡≡
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

LOG_DIR="log"
mkdir -p "$LOG_DIR"
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
LOG_FILE="${LOG_DIR}/build-output-${TIMESTAMP}.log"

# Log everything from now on
exec > >(tee -a "$LOG_FILE") 2>&1

echo "Build started at $(date)"
echo "Log file: $LOG_FILE"


# ≡≡≡≡≡≡≡≡≡ Configure environment ≡≡≡≡≡≡≡≡≡
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

export PATH="$PATH:/usr/bin:/sbin:/usr/sbin"

IMAGE="eQ-OS.raw"
OUTPUT_DIR="ISO"
KEYS_DIR="keys"
QEMU_DIR="qemu"


# ≡≡≡≡≡≡≡≡≡ Prepare build directories ≡≡≡≡≡≡≡≡≡
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

mkosi clean
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"
mkdir -p "$KEYS_DIR"


# ≡≡≡≡≡≡≡≡≡ Prepare keys ≡≡≡≡≡≡≡≡≡
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if [ ! -f "keys/mkosi.crt" ] || [ ! -f "keys/mkosi.key" ]; then
    (
        cd "$KEYS_DIR"
        mkosi genkey
    )
fi


# ≡≡≡≡≡≡≡≡≡ Build os image ≡≡≡≡≡≡≡≡≡
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "Running mkosi build..."

mkosi build

if [ ! -f "$OUTPUT_DIR/$IMAGE" ]; then
    echo "ERROR: Image not created!"
    exit 1
fi

echo "Image built successfully: $OUTPUT_DIR/$IMAGE"

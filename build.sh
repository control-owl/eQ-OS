#!/usr/bin/env bash
set -euox pipefail


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

OUTPUT_DIR="ISO"
IMAGE="eQ-OS.raw"
# KEYS_DIR="keys"
# QEMU_DIR="qemu"


# ≡≡≡≡≡≡≡≡≡ Prepare build directories ≡≡≡≡≡≡≡≡≡
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

mkosi clean -f || true
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"
# mkdir -p "$KEYS_DIR"


# ≡≡≡≡≡≡≡≡≡ Prepare keys ≡≡≡≡≡≡≡≡≡
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if [ ! -f "mkosi.key" ]; then
    mkosi genkey
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

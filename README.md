
# eQ-OS

> Bootable air-gapped Linux for the **eQ** crypto wallet.

eQ-OS is a minimal custom OS built with mkosi.  
It boots from USB in few seconds and starts [eQ](https://github.com/control-owl/eQ) in fullscreen kiosk mode.

No network. No internet. Kernel has no communication modules. Not even a sound.
Designed as secure cold storage wallet on a stick.

## Features

- Immutable root with dm-verity + signatures
- Keyboard disabled for extra security (Rubber Ducky and that shit)
- Mouse works inside eQ
- Debian Trixie base (minimal package set)
- Built with mkosi on Linux host
- Single user `eqos` with autologin on tty1
- Custom Plymouth theme and welcome MOTD


## Project status

| **Security Status**  |
| -------------------- |
| [![Verify GPG Signature](https://github.com/control-owl/eQ-OS/actions/workflows/verify-gpg-signature.yml/badge.svg)](https://github.com/control-owl/eQ-OS/actions/workflows/verify-gpg-signature.yml) |
| [![CodeQL](https://github.com/control-owl/eQ-OS/actions/workflows/github-code-scanning/codeql/badge.svg)](https://github.com/control-owl/eQ-OS/actions/workflows/github-code-scanning/codeql) |

| **ISO Build Status**     |
| -------------------- |
| [![Linux x86_64 GNU](https://github.com/control-owl/eQ-OS/actions/workflows/release-eQ-OS.yml/badge.svg)](https://github.com/control-owl/eQ-OS/actions/workflows/release-eQ-OS.yml) |

## mkosi Configuration

- **Distribution**: Debian trixie
- **Format**: disk (raw image with partitions)
- **Bootloader**: GRUB (BIOS + UEFI support)
- **Validation**: Verity + signatures (keys/mkosi.key + mkosi.crt)
- **Kernel cmdline**: quiet splash, low logging, no audit
- **Packages**: Only essentials + minimal X11 (xserver-xorg, libinput, mesa, plymouth, etc.)
- **RemoveFiles**: Cleans docs, man pages, locales, caches for small size

Partitions are defined in `mkosi.repart/`:
- ESP
- Signed verity root
- Home (read/write for wallet data)

## Security

- Xorg runs without systemd-logind
- No unnecessary services
- Root is immutable
- All changes stay on the USB stick only

## How to build

1. Clone this repository
2. Make sure build dependencies are installed (mkosi, qemu, etc.)
3. Run the build:

```bash
./build.sh
```

The script:
- Cleans previous builds
- Runs `mkosi build`
- Creates image in `ISO/` folder
- Prepares QEMU for quick testing (with OVMF UEFI)

## How to test in QEMU

The `build.sh` automatically starts QEMU after build.  
You can also run it manually for testing.

## How to write to USB

After build, write the raw image to a USB stick:

```bash
sudo dd if=ISO/eQ-OS.raw of=/dev/sdX bs=4M status=progress conv=fsync
```

Replace `/dev/sdX` with your USB device.  

## How to use

1. Insert the USB stick
2. Boot from it (set BIOS/UEFI to boot from USB)
3. Wait
4. **eQ** wallet starts automatically in fullscreen

Mouse works. Keyboard is ignored!

## Xorg Kiosk Config

Located in `mkosi.extra/etc/X11/xorg.conf.d/`:

- **10-fbdev.conf** — Uses modesetting driver
- **20-input.conf** — Disables keyboard, enables mouse with libinput
- **30-kiosk.conf** — No logind, no VT switch, no screen blanking
- **40-libinput.conf** — Pointer fallback

## Warning

This is a **<u>BETA!!!!</u>** security tool. I am trying to create cold USB storage. Do not use for production!
You can test it, it is working very fine for now, but I will redesign this over and over until I find perfect combination how to resolve eQ updating, root immutability, and find a perfect way to create encrypted partition for wallet storage.


---


If you think this makes any sense, buy me a beer or a coffee...


<a href="https://buymeacoffee.com/control.owl">
  <img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me a Coffee" width="200" height="60">
</a>
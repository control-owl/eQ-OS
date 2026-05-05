
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
| [![[Projects/eQ-OS/README/attachments/993c91d0783edcb61bfa8a0727c76aff_MD5.svg]]](https://github.com/control-owl/eQ-OS/actions/workflows/verify-gpg-signature.yml) |
| [![[Projects/eQ-OS/README/attachments/8e233ecd5b48d95ebc594b1266842fba_MD5.svg]]](https://github.com/control-owl/eQ-OS/actions/workflows/github-code-scanning/codeql) |

| **ISO Build Status**                                                                                                                                        |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [![[Projects/eQ-OS/README/attachments/3b7d98bda37b083c215a84b676307194_MD5.svg]]](https://github.com/control-owl/eQ-OS/actions/workflows/release-eQ-OS.yml) |

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

## Xorg Kiosk Config

Located in `mkosi.extra/etc/X11/xorg.conf.d/`:

- **10-fbdev.conf** — Uses modesetting driver
- **20-input.conf** — Disables keyboard, enables mouse with libinput0
- **30-kiosk.conf** — No logind, no VT switch, no screen blanking
- **40-libinput.conf** — Pointer fallback

## How to build

### Clone this repository
   
```shell
git clone -b stable --single-branch https://github.com/control-owl/eQ-OS.git
```

> Make sure build dependencies are installed (mkosi, qemu, etc.)

### Run the build script

```bash
./build.sh
```

The script:
- Cleans previous builds
- Runs `mkosi build`
- Creates image in `ISO/` folder

### Test the build script

```shell
./test

# or

mkosi qemu

# or

# mount ISO/eQ-OS.raw with gnome-boxes or someting like that
```

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

## Warning

This is a **<u>BETA!!!!</u>** security tool. I am trying to create cold USB storage. Do not use for production!
You can test it, it is working very fine for now, but I will redesign this over and over until I find perfect combination how to resolve eQ updating, root immutability, and find a perfect way to create encrypted partition for wallet storage.


---



<div style="background: #070410; color: #014070; padding: 20px; border-radius: 8px; margin: 30px 0;">
  <p><strong><span style="font-weight:900">You</span> like my project? 🙂</strong></p>
  <p>You <span style="font-weight:900">think</span> you will use my app? 😄<br>You find <span style="font-weight:900">this</span> awesome? 🤩<br>Yeah, I know - it <span style="font-weight:900">is</span> awesome. 😎<br>You know what else is <span style="font-weight:900">awesome</span>?<br>This yellow donation button down here. ⬇️</p>
<a href="https://www.buymeacoffee.com/control.owl"><img src="https://media1.giphy.com/media/v1.Y2lkPTc5MGI3NjExa3F2ajNhd3FqdXc3MGV0Znh2ZGwyM2xzcmhrOG5vdWltaGx0bHV0NiZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9cw/513lZvPf6khjIQFibF/giphy.gif" /></a>
  <p style="font-size: 14px; margin-top: 15px;">If not, that's cool too - at least you made it this far! 😅</p>
</div>




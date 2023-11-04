# PengOS
Small 16 bit operating system kernel project

## Usage
to use with qemu:
./run

to write to bootable USB, assemble the source with

nasm boot+kernel.asm -f bin -o ./builds/full.bin
dd if=./builds/full.bin of=/dev/[NAME OF USB DEVICE FILE] && sync

then can select to boot from usb drive and it should work

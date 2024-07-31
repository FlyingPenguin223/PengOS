# PengOS

Small 16 bit operating system kernel project

**PengOS** is a 16 bit operating system and environment for testing and running bare-metal programs. 

Most operating systems (like Windows and Linux) have measures put in place that prevent any "raw" binaries (which are just pure x86 machine code) from running. This means that, normally, the only way to run bare metal programs is for the bootloader to boot into that program directly, which has the issue of requiring you to give up your operating system altogether. **PengOS** seeks to rectify this issue by providing an environment where all programs run directly on bare metal. When you run a program in **PengOS**, the shell simply jumps CPU execution to the contents of the binary that was run. 

## Usage

Getting **PengOS** up and running takes only a few steps:

### Dependencies

First, make sure you have QEMU and NASM installed by running `whereis qemu` followed by `whereis nasm` in Bash (if you have them installed, a file path should show up. If you don't, you'll likely just see `qemu:` and/or `nasm:` printed to the screen). If you don't have one or both of the programs installed, use the package manager of your choice to install them. We recommend installing the `qemu-full` option to minimize the amount of setup you need to do post-installation. On Arch based distributions, this is done through 

`sudo pacman -S qemu-full` 

NASM can be installed on Arch based distributions through 

`sudo pacman -S nasm` 

(please make sure you know what you're doing before running random shell commands that you've found off the internet)

### Clone PengOS to your local system

Please read [this tutorial](https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository) from GitHub which explains how to clone a repository to your local system. Follow these steps with the **PengOS** repository in order to have all of the **PengOS** files downloaded onto your computer. 

### Run PengOS with QEMU

With QEMU installed, you can launch **PengOS** in a virtualized environment. First, make sure you have virtualization enabled on your machine (this is usually done through BIOS). Next, use the command line and navigate to your local clone of **PengOS**, then type the following command:

`./run`

This will launch **PengOS** in a QEMU window, which should show up on screen.

### Write PengOS to a Bootable USB (Danger Zone)

**(NOTICE: PLEASE DO NOT FOLLOW THE INSTRUCTIONS IN THIS SECTION UNLESS YOU KNOW WHAT YOU'RE DOING. IT IS VERY POSSIBLE TO BRICK A USB OR PERMENANTLY LOSE DATA IF YOU FOLLOW THESE INSTRUCTIONS BLINDLY. MAKE SURE YOU UNDERSTAND WHAT THESE COMMANDS DO BEFORE RUNNING THEM.)**

If you intend to install **PengOS** as an operating system onto another machine, navigate to your local clone of **PengOS** and run the following commands:

`nasm boot+kernel.asm -f bin -o ./builds/full.bin`

`dd if=./builds/full.bin of=/dev/[NAME OF USB DEVICE FILE] && sync`

From there, it is up to you to boot **PengOS** from your USB drive. 

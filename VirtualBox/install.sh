#!/bin/bash

##Arch setup

# Create partitions
sgdisk /dev/sda --zap-all
sgdisk /dev/sda --new=1:0:+512M --typecode=1:ef00 --new=2:0:+8G --typecode=2:8200 --largest-new=3 --typecode=3:8300

# Create filesystems
mkfs.fat -F 32 /dev/sda1
mkswap /dev/sda2
mkfs.ext4 /dev/sda3

# Mounting
mount /dev/sda3 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
swapon /dev/sda2

# Modify mirrorlist
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
reflector --verbose --sort rate --country AT,BE,DK,FI,FR,DE,GR,IE,IT,LU,NL,PT,ES,SE,GB --save /etc/pacman.d/mirrorlist

# Install base system
pacstrap /mnt base base-devel linux linux-firmware

# Generate fstab with IDs
genfstab -Up /mnt > /mnt/etc/fstab

curl https://raw.githubusercontent.com/ddeimling/arch-install/master/VirtualBox/chroot.sh > /mnt/chroot.sh
arch-chroot /mnt bash chroot.sh
rm /mnt/chroot.sh

# Cleanup & have fun
# swapoff /dev/sda2
# umount /dev/sda1
# umount /dev/sda3
# reboot
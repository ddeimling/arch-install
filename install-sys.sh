#!/bin/bash

##Arch base system setup

# Create partitions
sgdisk /dev/sda --zap-all
sgdisk /dev/sda --new=1:0:+512M --typecode=1:ef00 --new=2:0:+20G --typecode=2:8200 --new=3:0:+30G --typecode=3:8300 --new=4:0:0 --typecode=4:8300

# Create filesystems
mkfs.fat -F 32 /dev/sda1
mkswap /dev/sda2
mkfs.ext4 /dev/sda3
mkfs.ext4 /dev/sda4

# Mounting
mount /dev/sda3 /mnt
mkdir /mnt/boot
mkdir /mnt/home
mount /dev/sda1 /mnt/boot
mount /dev/sda4 /mnt/home
swapon /dev/sda2

# Modify mirrorlist
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
reflector --verbose --sort rate --country AT,BE,DK,FI,FR,DE,GR,IE,IT,LU,NL,PT,ES,SE,GB --save /etc/pacman.d/mirrorlist

# Install base system
pacstrap /mnt base base-devel linux linux-firmware intel-ucode

# Generate fstab with IDs
genfstab -Up /mnt > /mnt/etc/fstab

# Continue in chroot
curl https://raw.githubusercontent.com/ddeimling/arch-install/master/install-chroot.sh > /mnt/install-chroot.sh
arch-chroot /mnt bash install-chroot.sh
rm /mnt/install-chroot.sh


## Cleanup & have fun :D
swapoff /dev/sda2
umount /dev/sda1
umount /dev/sda4
umount /dev/sda3
reboot

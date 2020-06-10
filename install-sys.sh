#!/bin/bash

#Arch base system installation

# Create partitions
sgdisk /dev/sda --zap-all
sgdisk /dev/sda --new=1:0:512M --typecode:0:ef00
sgdisk /dev/sda --new=2:0:20G --typecode:0:8200
sgdisk /dev/sda --new:3:0:30G --typecode:0:8300
sgdisk /dev/sda --new:4:0:0 --typecode:0:8300

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

# Generate fstab with IDs
genfstab -Up /mnt >> /mnt/etc/fstab

# Modify mirrorlist
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist.bak
grep -E -A 1 ".*Germany.*$" /etc/pacman.d/mirrorlist.bak | sed '/--/d' > /etc/pacman.d/mirrorlist
pacman -Sy

# Install base system
pacstrap /mnt base base-devel linux linux-firmware intel-ucode

# Continue with install-chroot.sh
arch-chroot /mnt bash install-chroot.sh

swapoff /dev/sda2
umount /dev/sda1
umount /dev/sda4
umount /dev/sda3
reboot

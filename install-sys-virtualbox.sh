#!/bin/bash

##Arch base system setup

# Create partitions
sgdisk /dev/sda --zap-all
sgdisk /dev/sda --new=1:0:+256M --typecode=1:ef00 --new=2:0:+8G --typecode=2:8200 --largest-new=3 --typecode=3:8300

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
reflector --verbose --sort rate --country Austria,Belgium,Denmark,Finland,France,Germany,Greece,Ireland,Italy,Luxembourg,Netherlands,Portugal,Spain,Sweden,GB --save /etc/pacman.d/mirrorlist

# Install base system
pacstrap /mnt base base-devel linux linux-firmware virtualbox-guest-utils nano

# Generate fstab with IDs
genfstab -Up /mnt > /mnt/etc/fstab

# Continue in chroot
#curl https://raw.githubusercontent.com/ddeimling/arch-install/master/install-chroot-virtualbox.sh > /mnt/install-chroot-virtualbox.sh
#arch-chroot /mnt bash install-chroot.sh
#rm /mnt/install-chroot.sh


## Cleanup & have fun :D
swapoff /dev/sda2
umount /dev/sda1
umount /dev/sda4
umount /dev/sda3
reboot

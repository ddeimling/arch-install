#!/bin/bash
##Arch base system setup

# Create partitions
sgdisk /dev/sda --zap-all
sgdisk /dev/sda --new=1:0:+256M --typecode=1:ef00
sgdisk /dev/sda --new=2:0:+8G --typecode=2:8200
sgdisk /dev/sda --largest-new=3 --typecode=3:8300

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
pacstrap /mnt base base-devel linux linux-firmware grub efibootmgr virtualbox-guest-utils dhcpcd nano

# Generate fstab with IDs
genfstab -Up /mnt > /mnt/etc/fstab

# Set hostname
echo Arch-VM > /mnt/etc/hostname

# Configure console
echo KEYMAP=de-latin1 > /mnt/etc/vconsole.conf
echo FONT=lat9w-16 >> /mnt/etc/vconsole.conf

# Configure locale
sed -i "s|#de_DE.UTF-8|de_DE.UTF-8|" /mnt/etc/locale.gen
sed -i "s|#en_US.UTF-8|en_US.UTF-8|" /mnt/etc/locale.gen
arch-chroot /mnt locale-gen

#arch-chroot /mnt localectl --no-ask-password --no-convert set-locale de_DE.UTF-8

## Cleanup & have fun :D
#swapoff /dev/sda2
#umount /dev/sda1
#umount /dev/sda4
#umount /dev/sda3
#reboot


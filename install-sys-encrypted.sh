#!/bin/bash
# Arch Installation

# Kill existing partition layout
sgdisk /dev/sda --zap-all

# Create partition layout: EFI Boot with and LVM on top of LUKS encrypted partition
sgdisk /dev/sda --new=1:0:+512M --typecode=1:ef00 --new=2:0:0 --typecode=2:8309

# Read desired password for encryption
read -s -p "Encryption password: " encryptionPassword

# Create LUKS encrypted container
echo -e "${encryptionPassword}\n${encryptionPassword}" | cryptsetup luksFormat /dev/sda2

# Open LUKS container
echo $encryptionPassword | cryptsetup luksOpen /dev/sda2 cryptContainer

# Create physical volume and volume group
pvcreate /dev/mapper/cryptContainer
vgcreate vg_arch /dev/mapper/cryptContainer

# Get RAM size and calculate swap size
physMem=$(free --giga | tr -s ' ' | sed '/^Mem/!d' | cut -d" " -f2)
swapSize=$((physMem * 3/2))

# Create logical volumes
lvcreate -L "${swapSize}G" -n swap
lvcreate -L 35G -n root
lvcreate -l 100%FREE -n home

# Format & mount volumes
mkfs.fat -F 32 /dev/sda1
mkswap /dev/mapper/vg_arch/swap
mkfs.ext4 /dev/mapper/vg_arch/root
mkfs.ext4 /dev/mapper/vg_arch/home

mount /dev/mapper/vg_arch/root /mnt

mkdir /mnt/boot
mount /dev/sda1 /mnt/boot

mkdir /mnt/home
mount /dev/mapper/vg_arch/home /mnt/home

swapon /dev/mapper/vg_arch/swap

# Prepare mirrorlist
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
grep -E -A 1 ".*Germany.*$" /etc/pacman.d/mirrorlist.bak | sed '/--/d' > /etc/pacman.d/mirrorlist

# Base system installation
pacstrap /mnt base base-devel linux linux-firmware mkinitcpio intel-ucode lvm2 dhcpcd wpa_supplicant netctl dialog grub efibootmgr

#Generate fstab
genfstab -Up /mnt > /mnt/etc/fstab

# Configure mkinitcpio
sed -i 's|^HOOKS=\(.*\)|HOOKS=(base udev autodetect keyboard keymap consolefont modconf block encrypt lvm2 filesystems fsck)' /etc/mkinitcpio.conf

# Regenerate initramfs
arch-chroot /mnt mkinitcpio -p linux

#Configure grub
sed -i 's|#GRUB_ENABLE_CRYPTODISK=y|GRUB_ENABLE_CRYPTODISK=y' /etc/default/grub
uuid=$(lsblk -no UUID /dev/sda2)
sed -i 's|GRUB_CMDLINE_LINUX=""|GRUB_CMDLINE_LINUX="cryptdevice=UUID=$uuid:cryptContainer root=/dev/mapper/vg_arch/root"' /etc/default/grub

# Install grub boot loader
arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Grub

# Generate grub configuration file
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
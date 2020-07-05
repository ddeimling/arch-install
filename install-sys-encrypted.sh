#!/bin/bash
# Arch Installation

# Kill existing partition layout
sgdisk /dev/sda --zap-all

# Create partition layout: EFI Boot with and LVM on top of LUKS encrypted partition
sgdisk /dev/sda --new=1:0:+512M --typecode=1:ef00 --new=2:0:0 --typecode=2:8309

# Read desired password for encryption
#read -s -p "Encryption password: " encryptionPassword

# Create LUKS encrypted container (using --type luks1 until grub supports luks2)
#echo -e "${encryptionPassword}\n${encryptionPassword}" | cryptsetup luksFormat /dev/sda2
cryptsetup --type luks1 --cipher aes-xts-plain64 --key-size 512 --hash sha512 --use-random --iter-time 5000 --verify-passphrase luksFormat /dev/sda2

# Open LUKS container
#echo $encryptionPassword | cryptsetup luksOpen /dev/sda2 pv_arch
cryptsetup luksOpen /dev/sda2 pv_arch

# Create physical volume and volume group
pvcreate /dev/mapper/pv_arch
vgcreate vg_arch /dev/mapper/pv_arch

# Get RAM size and calculate swap size
physMem=$(free --giga | tr -s ' ' | sed '/^Mem/!d' | cut -d" " -f2)
swapSize=$((physMem * 3/2))

# Create logical volumes
lvcreate vg_arch -L "${swapSize}G" -n swap
lvcreate vg_arch -L 35G -n root
lvcreate vg_arch -l 100%FREE -n home

# Format & mount volumes
mkfs.vfat -F 32 /dev/sda1
mkswap /dev/mapper/vg_arch/swap
mkfs.ext4 /dev/mapper/vg_arch/root
mkfs.ext4 /dev/mapper/vg_arch/home

mount /dev/mapper/vg_arch/root /mnt

mkdir /mnt/boot
mkdir /mnt/efi
mount /dev/sda1 /mnt/efi

mkdir /mnt/home
mount /dev/mapper/vg_arch/home /mnt/home

swapon /dev/mapper/vg_arch/swap

# Prepare mirrorlist
#cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
#grep -E -A 1 ".*Germany.*$" /etc/pacman.d/mirrorlist.bak | sed '/--/d' > /etc/pacman.d/mirrorlist
#reflector --verbose --country 'Germany' --latest 50 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

# Base system installation
pacstrap /mnt base base-devel linux linux-firmware intel-ucode lvm2 dhcpcd wpa_supplicant netctl dialog grub efibootmgr nano

# Generate fstab
genfstab -Up /mnt > /mnt/etc/fstab

# System localization
echo Arch-LNB > /mnt/etc/hostname
echo KEYMAP=de-latin1 > /mnt/etc/vconsole.conf
echo FONT=lat9w-16 >> /mnt/etc/vconsole.conf
ln -sf /mnt/usr/share/zoneinfo/Europe/Berlin /mnt/etc/localtime
sed -i "s|#de_DE|de_DE|g" /mnt/etc/locale.gen
sed -i "s|#en_US|en_US|g" /mnt/etc/locale.gen
arch-chroot /mnt locale-gen

# Configure mkinitcpio
sed -i 's|^HOOKS=\(.*\)|HOOKS=(base udev autodetect keyboard keymap consolefont modconf block encrypt lvm2 filesystems fsck)|' /mnt/etc/mkinitcpio.conf

# Regenerate initramfs
arch-chroot /mnt mkinitcpio -p linux

# Configure grub
sed -i 's|#GRUB_ENABLE_CRYPTODISK=y|GRUB_ENABLE_CRYPTODISK=y|' /mnt/etc/default/grub
uuid=$(blkid -s UUID -o value /dev/sda2)
sed -i "s|GRUB_CMDLINE_LINUX=\"\"|GRUB_CMDLINE_LINUX=\"cryptdevice=UUID=$uuid\:pv_arch root=/dev/vg_arch/root\"|" /mnt/etc/default/grub

# Install grub boot loader
arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=Grub

# Generate grub configuration file
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

#!/bin/bash
##Arch base system setup

# if ! pacman -Qs dialog > /dev/null
#     then pacman --noconfirm -S dialog

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
pacstrap /mnt base base-devel linux linux-firmware

# Generate fstab with IDs
genfstab -Up /mnt > /mnt/etc/fstab

# Set hostname
echo Arch-Desktop > /mnt/etc/hostname

# Configure console
echo KEYMAP=de-latin1 > /mnt/etc/vconsole.conf
echo FONT=lat9w-16 >> /mnt/etc/vconsole.conf

# Configure locale
sed -i "s|#de_DE|de_DE|" /mnt/etc/locale.gen
sed -i "s|#en_US|en_US|" /mnt/etc/locale.gen
arch-chroot /mnt locale-gen

# Set the timezone
arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime

# Set 'sudo'
arch-chroot /mnt pacman --noconfirm --needed -S sudo
sed -i 's|# %wheel ALL=(ALL) ALL|%wheel ALL=(ALL) ALL|' /etc/sudoers

# Useful services
arch-chroot /mnt pacman --noconfirm --needed -S acpid
systemctl enable acpid

arch-chroot /mnt pacman --noconfirm --needed -S avahi
systemctl enable avahi-daemon

arch-chroot /mnt pacman --noconfirm --needed -S cups
systemctl enable org.cups.cupsd

arch-chroot /mnt pacman --noconfirm --needed -S networkmanager
systemctl enable NetworkManager

arch-chroot /mnt pacman --noconfirm --needed -S cronie
systemctl enable cronie

# VirtualBox guest additions
arch-chroot /mnt pacman --noconfirm --needed -S virtualbox-guest-modules-arch virtualbox-guest-utils
echo vboxguest >> /mnt/etc/modules-load.d/virtualbox.conf
echo vboxsf >> /mnt/etc/modules-load.d/virtualbox.conf
echo vboxvideo >> /mnt/etc/modules-load.d/virtualbox.conf
arch-chroot /mnt systemctl enable vboxservice

# Xorg, Desktop & Login
arch-chroot /mnt pacman --noconfirm --needed -S xorg-server xorg-xinit gnome gdm
arch-chroot /mnt systemctl enable gdm

# Set root password
arch-chroot /mnt passwd

# Generate initramfs
arch-chroot /mnt mkinitcpio -p linux

# Setup GRUB
arch-chroot /mnt pacman --noconfirm --needed -S grub efibootmgr
arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Arch-Grub
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

# Cleanup
swapoff /dev/sda2
umount /dev/sda1
umount /dev/sda4
umount /dev/sda3
reboot
#!/bin/bash

##Arch base system setup

# Create partitions
sgdisk /dev/sda --zap-all
sgdisk /dev/sda --new=1:0:+512M --typecode=1:ef00 --new=2:0:+8G --typecode=2:8200 --largest-new=3 --typecode=3:8300

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
pacstrap /mnt base base-devel linux linux-firmware grub efibootmgr nano dhcpcd bash-completion virtualbox-guest-utils

# Generate fstab with IDs
genfstab -Up /mnt > /mnt/etc/fstab

# Configure locale
sed -i "s|#de_DE.UTF-8|de_DE.UTF-8|" /mnt/etc/locale.gen
sed -i "s|#en_US.UTF-8|en_US.UTF-8|" /mnt/etc/locale.gen
arch-chroot /mnt locale-gen

# Set the timezone
arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime

# Set 'sudo'
arch-chroot /mnt pacman --noconfirm --needed -S sudo
sed -i 's|# %wheel ALL=(ALL) ALL|%wheel ALL=(ALL) ALL|' /mnt/etc/sudoers

# Useful services
arch-chroot /mnt pacman --noconfirm --needed -S acpid
arch-chroot /mnt systemctl enable acpid

arch-chroot /mnt pacman --noconfirm --needed -S avahi
arch-chroot /mnt systemctl enable avahi-daemon

arch-chroot /mnt pacman --noconfirm --needed -S cups
arch-chroot /mnt systemctl enable org.cups.cupsd

arch-chroot /mnt pacman --noconfirm --needed -S networkmanager
arch-chroot /mnt systemctl enable NetworkManager

arch-chroot /mnt pacman --noconfirm --needed -S cronie
arch-chroot /mnt systemctl enable cronie

# Xorg, Desktop & Login
arch-chroot /mnt pacman --noconfirm --needed -S xorg-server xorg-xinit gnome gdm
arch-chroot /mnt systemctl enable gdm

# Generate initramfs
arch-chroot /mnt mkinitcpio -p linux

# Setup GRUB
arch-chroot /mnt pacman --noconfirm --needed -S grub efibootmgr
arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Grub
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

# Change root passwd
arch-chroot /mnt echo -e "root\nroot" | passwd root

# Add user
arch-chroot /mnt useradd -m -g users -s /bin/bash daniel
arch-chroot /mnt gpasswd -a daniel wheel
arch-chroot /mnt gpasswd -a daniel audio
arch-chroot /mnt gpasswd -a daniel video
arch-chroot /mnt gpasswd -a daniel games
arch-chroot /mnt gpasswd -a daniel power
arch-chroot /mnt echo -e "daniel\ndaniel" | passwd daniel

## Cleanup & have fun :D
swapoff /dev/sda2
umount /dev/sda1
umount /dev/sda3
reboot
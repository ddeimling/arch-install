#!/bin/bash

# Set hostname
echo Arch-Desktop > /etc/hostname

# Set the timezone
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime

# Set the root default password
echo -e 'root\nroot' | passwd root

# Generate locale
locale-gen

# Install tools & software

# System tools
pacman --noconfirm --needed -S hdparm sudo acpid dbus avahi cups cronie networkmanager

# Desktop, graphics & login manager
pacman --noconfirm --needed -S xorg-server xorg-xinit nvidia nvidia-utils sddm sddm-kcm plasma awesome

# Other (e. g. dependencies for themin sddm)
pacman --noconfirm --needed -S qt5-graphicaleffects qt5-quickcontrols2 qt5-svg

# Tooling & Applications
pacman --noconfirm --needed -S bash-completion nano neovim terminator ttf-dejavu thunderbird firefox

# Enable services
systemctl enable acpid
systemctl enable avahi-daemon
systemctl enable org.cups.cupsd.service
systemctl enable NetworkManager.service
systenctl enable cronie
systemctl enable fstrim.timer
systemctl enable systemd-timesyncd.service
systemctl enable sddm

# Install sddm theme 'sugar-candy'
mkdir -p /usr/share/sddm/theme/sugar-candy
git clone https://framagit.org/MarianArlt/sddm-sugar-candy.git /usr/share/sddm/theme/sugar-candy

# Copy the salt
 

## Finishing ###
# Generate initramfs
mkinitcpio -p linux

# Install boot
pacman --noconfirm --needed -S grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Arch-Grub
grub-mkconfig -o /boot/grub/grub.cfg
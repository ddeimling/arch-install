#!/bin/bash

## Initializing

# Check updates
#pacman-key --init
#pacman-key --populate
#pacman-key --refresh-keys
pacman --noconfirm -Syu


## Install tools & software

# System tools
pacman --noconfirm --needed -S hdparm sudo acpid dbus avahi cups cronie networkmanager

# Desktop, graphics & login manager
pacman --noconfirm --needed -S xorg-server xorg-xinit nvidia nvidia-utils sddm cinnamon awesome ttf-dejavu

# Other (e. g. dependencies for themin sddm)
pacman --noconfirm --needed -S qt5-graphicaleffects qt5-quickcontrols2 qt5-svg

# Tooling & Applications
pacman --noconfirm --needed -S bash-completion nano neovim terminator thunderbird firefox git nodejs


## Configure system

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
mkdir -p /usr/share/sddm/themes/sugar-candy
git clone https://framagit.org/MarianArlt/sddm-sugar-candy.git /usr/share/sddm/themes/sugar-candy


## Setup system environment

# Set hostname
echo Arch-Desktop > /etc/hostname

# Set the timezone
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime

# Set the root default password ( CHANGE ROOT PASSWORD AFTER SYSTEM SETUP HAS FINISHED ! ! ! )
echo -e 'root\nroot' | passwd root

# Copy the salt

git clone https://github.com/ddeimling/arch-install /tmp/arch-install
cp -r /tmp/arch-install/salt/* /
rm -rf /tmp/arch-install


### Finishing ###

# Generate locale
locale-gen

# Generate initramfs
mkinitcpio -p linux

# Install boot
pacman --noconfirm --needed -S grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Arch-Grub
grub-mkconfig -o /boot/grub/grub.cfg

# Add user
useradd -m -G wheel,log,network,audio,video,games,power -s /bin/bash daniel
echo -e 'daniel\ndaniel' | passwd daniel

mkdir -p /home/daniel/documents
mkdir -p /home/daniel/downloads
mkdir -p /home/daniel/workspace
mkdir -p /home/daniel/pictures
mkdir -p /home/daniel/music
mkdir -p /home/daniel/videos
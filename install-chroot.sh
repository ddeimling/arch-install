#!/bin/bash
# Set hostname
echo Arch-Desktop > /etc/hostname

# Configure & generate locale
echo "de_DE.UTF-8 UTF-8" >> /etc/locale.gen
echo "de_DE ISO-8859-1" >> /etc/locale.gen
echo "de_DE@euro ISO-8859-15" >> /etc/locale.gen
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "en_US ISO-8859-1" >> /etc/locale.gen
locale-gen

# Set keyboard layout & font
echo KEYMAP=de-latin1 > /etc/vconsole.conf
echo FONT=lat9w-16 >> /etc/vconsole.conf

# Set the timezone
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime

# Activate sudo group 'wheel' in /etc/sudoers
sed -i 's|# %wheel All=(ALL) ALL|%wheel All=(ALL) ALL|g' /etc/sudoers

# Install & activate services
pacman --noconfirm --needed acpid dbus avahi cups cronie networkmanager
systemctl enable acpid
systemctl enable avahi-daemon
systemctl enable org.cups.cupsd.service
systemctl enable NetworkManager.service
systenctl enable --now cronie
systemctl enable --now fstrim.timer
systemctl enable --now systemd-timesyncd.service

# Set hardware clock from system clock
hwclock --systohc

# Install & configure X
pacman --noconfirm --needed -S xorg-server xorg-xinit nvidia nvidia-utils

# Install & configure desktop
pacman --noconfirm --needed lightdm lightdm-gtk-greeter cinnamon awesome
sed -i 's|greeter-session=lightdm-yourgreeter-greeter|greeter-session=lightdm-gtk-greeter|g' /etc/mkinitcpio.conf
systemctl enable lightdm

#Deactivation pc speaker ("beeping" when using shell)
cp nobeep.conf /etc/modprobe.d
sed -i 's|FILES=()|FILES=(/etc/modprobe.d/nobeep.conf)|g' /etc/mkinitcpio.conf

# Generate initramfs
mkinitcpio -p linux

# Install boot
pacman --noconfirm --needed -S grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Arch-Grub
grub-mkconfig -o /boot/grub/grub.cfg

# Set the root default password
chpasswd root:root
useradd -m -g users -s /bin/bash daniel
gpasswd -a daniel wheel
gpasswd -a daniel audio
gpasswd -a daniel video
gpasswd -a daniel power
gpasswd -a daniel games

# Install some essential tools
pacman --noconfirm --needed thunderbird firefox alsa-utils libreoffice gimp vlc

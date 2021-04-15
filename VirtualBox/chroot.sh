#!/bin/bash

rootPassword="root"
userName="daniel"
userPassword="daniel"

# Install needed tools, software & services
pacman --noconfirm --needed -S virtualbox-guest-utils sudo grub efibootmgr nano vim dhcpcd bash-completion acpid avahi cups cronie xorg-server xorg-xinit gdm gnome terminator

# Set hostname
echo Arch-Desktop-VM > /etc/hostname

# Configure console
echo KEYMAP=de-latin1 > /etc/vconsole.conf
echo FONT=lat9w-16 >> /etc/vconsole.conf

# Configure locale
echo LANG=de_DE.UTF-8 > /etc/locale.conf
echo LANGUAGE=de_DE >> /etc/locale.conf
sed -i "s|#de_DE.UTF-8|de_DE.UTF-8|" /etc/locale.gen
sed -i "s|#en_US.UTF-8|en_US.UTF-8|" /etc/locale.gen
locale-gen

# Set the timezone
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime

# Enable 'sudo' for group 'wheel'
sed -i 's|# %wheel ALL=(ALL) ALL|%wheel ALL=(ALL) ALL|' /etc/sudoers

# Enable services
systemctl enable vboxservice
systemctl enable dhcpcd
systemctl enable acpid
systemctl enable avahi-daemon
systemctl enable org.cups.cupsd
systemctl enable NetworkManager
systemctl enable cronie
systemctl enable gdm

# Add user
useradd -m -g users -G wheel,audio,video,games,power -s /bin/bash $userName
echo -e "${userPassword}\n${userPassword}" | passwd $userName

# Set root passwd
echo -e "${rootPassword}\n${rootPassword}" | passwd root

# Generate initramfs
mkinitcpio -p linux

# Setup GRUB
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Grub
grub-mkconfig -o /boot/grub/grub.cfg

#Exit chroot


#!/bin/bash

#Load and add blacklist.conf to file hooks
curl -O https://raw.githubusercontent.com/ddeimling/arch-install/master/blacklist.conf -o /etc/modprobe.d/blacklist.conf
sed -i 's|FILES=()|FILES=(/etc/modprobe.d/blacklist.conf)|g' /etc/mkinitcpio.conf

# Generate initramfs
mkinitcpio -p linux

# Install boot
pacman --noconfirm --needed -S grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Arch-Grub
grub-mkconfig -o /boot/grub/grub.cfg

# Install and configure hdparm
pacman -S --noconfirm --need hdparm
curl -O https://raw.githubusercontent.com/ddeimling/arch-install/master/69-hdparm.rules -o /etc/udev/rules.d/69-hdparm.rules

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

# Install & activate sudo group 'wheel' in /etc/sudoers
pacman --noconfirm --needed -S sudo
sed -i 's|# %wheel All=(ALL) ALL|%wheel All=(ALL) ALL|g' /etc/sudoers

# Install & activate services
pacman --noconfirm --needed -S acpid dbus avahi cups cronie networkmanager
systemctl enable acpid
systemctl enable avahi-daemon
systemctl enable org.cups.cupsd.service
systemctl enable NetworkManager.service
systenctl enable cronie
systemctl enable fstrim.timer
systemctl enable systemd-timesyncd.service

# Install & configure X
pacman --noconfirm --needed -S xorg-server xorg-xinit nvidia nvidia-utils
curl -O https://raw.githubusercontent.com/ddeimling/arch-install/master/20-keyboard.conf -o /etc/X11/xorg.conf.d/20-keyboard.conf

# Install & configure desktop
pacman --noconfirm --needed -S lightdm lightdm-gtk-greeter cinnamon awesome alsa-utils
sed -i 's|greeter-session=example-gtk-gnome|greeter-session=lightdm-gtk-greeter|g' /etc/lightdm/lightdm.conf
systemctl enable lightdm

# Install some tools
pacman --noconfirm --needed -S bash-completion nano neovim terminator ttf-dejavu

# Set the root default password
echo -e 'root\nroot' | passwd root
# Add user
sudo useradd -m -G wheel,audio,video,games,power -s /bin/bash daniel
echo -e 'daniel\ndaniel | passwd daniel

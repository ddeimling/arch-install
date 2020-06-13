#!/bin/bash
ROOT_DEFAULT_PASSWORD="root"
ADMINISTRATOR_NAME="arch-admin"
ADMINISTRATOR_DEFAULT_PASSWORD="arch-admin"
## Initializing

# Check updates
#pacman-key --init
#pacman-key --populate
#pacman-key --refresh-keys
pacman --noconfirm -Syu

## Configure system

# Set hostname
echo Arch-Desktop > /etc/hostname

# Configure console
echo KEYMAP=de-latin1 > /etc/vconsole.conf
echo FONT=lat9w-16 >> /etc/vconsole.conf

# Configure locale
echo LANG=de_DE.UTF-8 > /etc/locale.conf
sed -i "s/#de_DE/de_DE/" /etc/locale.gen
sed -i "s/#en_US/en_US/" /etc/locale.gen
locale-gen

localectl --no-ask-password set-locale de_DE.UTF-8
localectl --no-ask-password set-x11-keymap de pc105 nodeadkeys

# Set the timezone
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime

# Install & configure sudo
sudo pacman --noconfirm --needed -S sudo
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

# Useful services
systemctl enable fstrim.timer
systemctl enable systemd-timesyncd.service

pacman --noconfirm --needed -S acpid
systemctl enable acpid

pacman --noconfirm --needed -S avahi
systemctl enable avahi-daemon

pacman --noconfirm --needed -S cups
systemctl enable org.cups.cupsd.service

pacman --noconfirm --needed -S networkmanager
systemctl enable NetworkManager.service

pacman --noconfirm --needed -S cronie
systemctl enable cronie

# Xorg, Desktop & Login
pacman --noconfirm --needed -S xorg-server xorg-xinit nvidia nvidia-utils sddm cinnamon ttf-dejavu
systemctl enable sddm

# Install sddm theme "sugar-candy"
pacman --noconfirm --needed qt5-graphicaleffects qt5-quickcontrols2 qt5-svg git
mkdir -p /usr/share/sddm/themes/sugar-candy
git clone https://framagit.org/MarianArlt/sddm-sugar-candy.git /usr/share/sddm/themes/sugar-candy


# Set the root default password ( CHANGE ROOT PASSWORD AFTER SYSTEM SETUP HAS FINISHED ! ! ! )
echo -e "${ROOT_DEFAULT_PASSWORD}\n${ROOT_DEFAULT_PASSWORD}" | passwd root

# Copy the salt
git clone https://github.com/ddeimling/arch-install /tmp/arch-install
cp -r /tmp/arch-install/salt/* /
rm -rf /tmp/arch-install


### Finishing ###

# Generate initramfs
mkinitcpio -p linux

# Install boot
pacman --noconfirm --needed -S grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Arch-Grub
grub-mkconfig -o /boot/grub/grub.cfg

# Add special account for further installation, e. g. for yay (makepkg needs non-root user)
sudo pacman --noconfirm --needed sudo
useradd -m $ADMINISTRATOR_NAME
echo -e "${ADMINISTRATOR_DEFAULT_PASSWORD}\n${ADMINISTRATOR_DEFAULT_PASSWORD}" | passwd $ADMINISTRATOR_NAME
echo "%$ADMINISTRATOR_NAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

sudo -Hu $ADMINISTRATOR_NAME git clone https://aur.archlinux.org/yay.git /home/$ADMINISTRATOR_NAME/yay
cd /home/$ADMINISTRATOR_NAME/yay
sudo -Hu $ADMINISTRATOR_NAME makepkg -si --noconfirm

sudo -Hu $ADMINISTRATOR_NAME yay --noconfirm -S visual-studio-code-bin spotify

sed -i "/%$ADMINISTRATOR_NAME ALL=(ALL) NOPASSWD: ALL/d" /etc/sudoers
userdel -r $ADMINISTRATOR_NAME

# TODO: Install yay then with yay install visual-studio-code-bin, spotify
# curl https://raw.githubusercontent.com/ddeimling/arch-install/master/install-user.sh | installUser
# sudo -Hu daniel bash $installUser

# User specific configuration - needs to be extracted into something like install-user.sh
useradd -m -G wheel,log,network,audio,video,games,power -s /bin/bash daniel
sudo -Hu daniel dbus-launch gsettings set org.cinnamon.desktop.background picture-uri  "file:///usr/local/share/img/arch.jpg"
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
# echo LANG=de_DE.UTF-8 > /etc/locale.conf
sed -i "s|#de_DE|de_DE|" /etc/locale.gen
sed -i "s|#en_US|en_US|" /etc/locale.gen
locale-gen

localectl --no-ask-password --no-convert set-locale de_DE.UTF-8

# Set the timezone
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime

# Install & configure sudo
sudo pacman --noconfirm --needed -S sudo
sed -i 's|# %wheel ALL=(ALL) ALL|%wheel ALL=(ALL) ALL|' /etc/sudoers

# Useful services
systemctl enable fstrim.timer
systemctl enable systemd-timesyncd

pacman --noconfirm --needed -S acpid
systemctl enable acpid

pacman --noconfirm --needed -S avahi
systemctl enable avahi-daemon

pacman --noconfirm --needed -S cups
systemctl enable org.cups.cupsd

pacman --noconfirm --needed -S networkmanager
systemctl enable NetworkManager

pacman --noconfirm --needed -S cronie
systemctl enable cronie

# Xorg, Desktop & Login
pacman --noconfirm --needed -S xorg-server xorg-xinit nvidia nvidia-utils sddm cinnamon ttf-dejavu
systemctl enable sddm

# Install sddm theme "sugar-candy"
pacman --noconfirm --needed -S qt5-graphicaleffects qt5-quickcontrols2 qt5-svg git
mkdir -p /usr/share/sddm/themes/sugar-candy
git clone https://framagit.org/MarianArlt/sddm-sugar-candy.git /usr/share/sddm/themes/sugar-candy
curl https://raw.githubuserontent.com/ddeimling/arch-install/master/arch.jpg -o /user/share/sddm/themes/sugar-candy/Backgrounds/arch.jpg

mkdir /etc/sddm.conf.d
cp /usr/lib/sddm/sddm.conf.d/default.conf /etc/sddm.conf.d/sddm.conf

sed -i 's|Current=|Current=sugar-candy|' /etc/sddm.conf.d/sddm.conf
sed -i 's|ScreenWidth=".*"|ScreenWidth="1920"|' /user/share/sddm/themes/sugar-candy/theme.conf
sed -i 's|ScreenHeight=".*"|ScreenHeight="1080"|' /user/share/sddm/themes/sugar-candy/theme.conf
sed -i 's|ForceLasUser=".*"|ForceLastUser="true"|' /user/share/sddm/themes/sugar-candy/theme.conf
sed -i 's|ForcePasswordFocus=".*"|ForcePasswordFocus="true"|' /user/share/sddm/themes/sugar-candy/theme.conf
sed -i 's|Background=".*"|Background="Backgrounds/arch.jpg"|' /user/share/sddm/themes/sugar-candy/theme.conf

# Set the root default password ( CHANGE ROOT PASSWORD AFTER SYSTEM SETUP HAS FINISHED ! ! ! )
echo -e "${ROOT_DEFAULT_PASSWORD}\n${ROOT_DEFAULT_PASSWORD}" | passwd root

# Set special system configs
sudo pacman --noconfirm --needed -S hdparm
echo 'ACTION=="add|change", KERNEL=="sd[a-z]", ATTRS{queue/rotational}=="1", RUN+="/usr/bin/hdparm -S 36 /dev/%k"' > /usr/lib/udev/rules.d/69-hdparm.rules

### Finishing ###

# Configure & generate initramfs
echo "blacklist pcspkr" > /etc/modprobe.d/blacklist.conf
sed -i 's|FILES=()|FILES=(/etc/modprobe.d/blacklist.conf)|' /etc/modprobe.d/blacklist.conf
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
mkdir -p /home/daniel/wallpaper
curl https://raw.githubuserontent.com/ddeimling/arch-install/master/arch.jpg -o /home/daniel/wallpaper/arch.jpg
sudo -Hu daniel dbus-launch gsettings set org.cinnamon.desktop.background picture-uri  "file:///home/daniel/wallpaper/arch.jpg"
sudo -Hu daniel localectl --no-ask-password --no-convert set-x11-keymap de pc105 nodeadkeys
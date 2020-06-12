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


## Install tools & software

# System tools
pacman --noconfirm --needed -S hdparm sudo acpid dbus avahi cups cronie networkmanager git

# Desktop, graphics & login manager
pacman --noconfirm --needed -S xorg-server xorg-xinit nvidia nvidia-utils sddm cinnamon awesome ttf-dejavu

# Other (e. g. dependencies for themin sddm)
pacman --noconfirm --needed -S qt5-graphicaleffects qt5-quickcontrols2 qt5-svg

# Basic Tooling & Applications
pacman --noconfirm --needed -S terminator


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

# Install sddm theme "sugar-candy"
mkdir -p /usr/share/sddm/themes/sugar-candy
git clone https://framagit.org/MarianArlt/sddm-sugar-candy.git /usr/share/sddm/themes/sugar-candy


## Setup system environment

# Set hostname
echo Arch-Desktop > /etc/hostname

# Set the timezone
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime

# Set the root default password ( CHANGE ROOT PASSWORD AFTER SYSTEM SETUP HAS FINISHED ! ! ! )
echo -e "${ROOT_DEFAULT_PASSWORD}\n${ROOT_DEFAULT_PASSWORD}" | passwd root

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

# Add administrator for further installation, e. g. for yay (because of makepkg & root)
useradd -m $ADMINISTRATOR_NAME
echo -e "${ADMINISTRATOR_DEFAULT_PASSWORD}\n${ADMINISTRATOR_DEFAULT_PASSWORD}" | passwd $ADMINISTRATOR_NAME
echo "%$ADMINISTRATOR_NAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

sudo -Hu $ADMINISTRATOR_NAME git clone https://aur.archlinux.org/yay.git /home/$ADMINISTRATOR_NAME/yay
cd /home/$ADMINISTRATOR_NAME/yay
sudo -Hu $ADMINISTRATOR_NAME makepkg -si --noconfirm

sed -i "/%$ADMINISTRATOR_NAME ALL=(ALL) NOPASSWD: ALL/d" /etc/sudoers
userdel -r $ADMINISTRATOR_NAME

# TODO: Install yay then with yay install visual-studio-code-bin, spotify
# curl https://raw.githubusercontent.com/ddeimling/arch-install/master/install-user.sh | installUser
# sudo -Hu daniel bash $installUser


useradd -m -G wheel,log,network,audio,video,games,power -s /bin/bash daniel
sudo -Hu daniel dbus-launch gsettings set org.cinnamon.desktop.background picture-uri  "file:///usr/local/share/img/arch.jpg"
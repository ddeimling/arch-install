#!/bin/bash
# Arch Installation

# TODO
# 1. Create and use encrypted boot
# 2. Create and use encrypted swap
# 3. Create and use 


# Kill existing partition layout
sgdisk /dev/sda --zap-all

# Create partition layout: 1.) EFI Boot partition, 2.) LUKS partition
sgdisk /dev/sda --new=1:0:+512M --typecode=1:ef00 --new=2:0:+12G --typecode=3:8200 --new=3:0:0 --typecode=3:8309

# Create LUKS encrypted container
cryptsetup --type luks1 --cipher aes-xts-plain64 --key-size 512 --hash sha512 --use-random --iter-time 5000 --verify-passphrase luksFormat /dev/sda2

# Open LUKS container
cryptsetup luksOpen /dev/sda2 root

# Create filesystems
mkfs -F 32 /dev/sda1
mkfs.btrfs -L ARCH /dev/mapper/root

# Mount device
mount /dev/mapper/root /mnt

#Create subvolumes
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@opt
btrfs subvolume create /mnt/@srv
btrfs subvolume create /mnt/@tmp
btrfs subvolume create /mnt/@usr-local
btrfs subvolume create /mnt/@var-opt
btrfs subvolume create /mnt/@var-spool
btrfs subvolume create /mnt/@var-tmp
btrfs subvolume create /mnt/@var-log
btrfs subvolume create /mnt/@var-lib-pacman
btrfs subvolume create /mnt/@var-abs
btrfs subvolume create /mnt/@var-cache
mkdir -p /mnt/@var-cache/pacman/pkg
btrfs subvolume create /mnt/@var-cache-pacman-pkg

umount /mnt

# Mount with options (especially subvolume @)
mount -o subvol=@,compress=lzo,space_cache,ssd,noatime /dev/mapper/root /mnt

# Create directories
mkdir -p /mnt/home
mkdir -p /mnt/.snapshots
mkdir -p /mnt/opt
mkdir -p /mnt/srv
mkdir -p /mnt/tmp
mkdir -p /mnt/usr/local
mkdir -p /mnt/var/opt
mkdir -p /mnt/var/spool
mkdir -p /mnt/var/tmp
mkdir -p /mnt/var/log
mkdir -p /mnt/var/lib/pacman
mkdir -p /mnt/var/abs
mkdir -p /mnt/var/cache

#Mount subvolumes
mount -o subvol=@home,compress=lzo,space_cache,ssd,noatime /dev/mapper/root /mnt/home
mount -o subvol=@snapshots,compress=lzo,space_cache,ssd,noatime /dev/mapper/root /mnt/.snapshots
mount -o subvol=@opt,compress=lzo,space_cache,ssd,noatime /dev/mapper/root /mnt/opt
mount -o subvol=@srv,compress=lzo,space_cache,ssd,noatime /dev/mapper/root /mnt/srv
mount -o subvol=@tmp,compress=lzo,space_cache,ssd,noatime /dev/mapper/root /mnt/tmp
mount -o subvol=@usr-local,compress=lzo,space_cache,ssd,noatime /dev/mapper/root /mnt/usr/local
mount -o subvol=@var-opt,compress=lzo,space_cache,ssd,noatime /dev/mapper/root /mnt/var/opt
mount -o subvol=@var-spool,compress=lzo,space_cache,ssd,noatime /dev/mapper/root /mnt/var/spool
mount -o subvol=@var-tmp,compress=lzo,space_cache,ssd,noatime /dev/mapper/root /mnt/var/tmp
mount -o subvol=@var-log,compress=lzo,space_cache,ssd,noatime /dev/mapper/root /mnt/var/log
mount -o subvol=@var-lib-pacman,compress=lzo,space_cache,ssd,noatime /dev/mapper/root /mnt/var/lib/pacman
mount -o subvol=@var-abs,compress=lzo,space_cache,ssd,noatime /dev/mapper/root /mnt/var/abs
mount -o subvol=@var-cache,compress=lzo,space_cache,ssd,noatime /dev/mapper/root /mnt/var/cache
mount -o subvol=@var-cache-pacman-pkg,compress=lzo,space_cache,ssd,noatime /dev/mapper/root /mnt/var/cache/pacman/pkg
#!/bin/bash

createFolders(){
    mkdir -p /home/daniel/documents
    mkdir -p /home/daniel/downloads
    mkdir -p /home/daniel/workspace/repos
    mkdir -p /home/daniel/src
    mkdir -p /home/daniel/pictures
    mkdir -p /home/daniel/music
    mkdir -p /home/daniel/videos
}

installYay(){
    cd /home/daniel/src
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg --noconfirm -si
}

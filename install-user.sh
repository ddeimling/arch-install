#sudo -Hu daniel dbus-launch gsettings set org.cinnamon.desktop.background picture-uri  "file:///usr/local/share/img/arch.jpg"
gsettings set org.cinnamon.desktop.background picture-uri  "file:///usr/local/share/img/arch.jpg"

mkdir -p /home/$(whoami)/documents
mkdir -p /home/$(whoami)/downloads
mkdir -p /home/$(whoami)/workspace
mkdir -p /home/$(whoami)/pictures
mkdir -p /home/$(whoami)/music
mkdir -p /home/$(whoami)/videos
mkdir -p /home/$(whoami)/src


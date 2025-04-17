#!/bin/sh

set -e 

# Configurar /etc/hosts
sed -i "s/HOSTNAME/${HOSTNAME}/g" ./resources/hosts
rm -r /mnt/etc/hosts
mv ./resources/hosts /mnt/etc/hosts

# Configuration de pacman
rm -r /mnt/etc/pacman.conf
mv ./resources/pacman.conf /mnt/etc/pacman.conf
pacman -Syu --noconfirm

su - w15hy <<PAS
xdg-user-dirs-update

mkdir Sources
cd Sources

git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si --noconfirm
PAS

pacman -S python net-tools ly amd-ucode xf86-input-libinput tlp tlp-rdw powertop acpi ntp neovim git man

systemctl enable ly.service
systemctl enable tlp
systemctl mask systemd-rfkill.service
systemctl mask systemd-rfkill.socket
systemctl enable fstrim.timer
systemctl enable ntpd
systemctl start ntpd
systemctl enable bluetooth
ntpd -qg

#!/bin/sh

set -e 

# Configurar /etc/hosts
sed -i "s/HOSTNAME/${HOSTNAME}/g" ./resources/hosts
rm -r /etc/hosts
mv ./resources/hosts /etc/hosts

# Configuration de pacman
rm -r /etc/pacman.conf
mv ./resources/pacman.conf /etc/pacman.conf
pacman -Syu --noconfirm
pacman -S git --noconfirm

su - w15hy <<PAS
xdg-user-dirs-update

mkdir Sources
cd Sources

git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
PAS

# Install packages
pacman -S xorg-server xorg-apps xorg-xinit --noconfirm
pacman -S i3 numlockx --noconfirm
pacman -S noto-fonts ttf-ubuntu-font-family ttf-dejavu ttf-freefont --noconfirm
pacman -S ttf-liberation ttf-droid ttf-roboto terminus-font --noconfirm
pacman -S firefox --noconfirm
pacman -S bluez bluez-utils  --noconfirm
pacman -S python net-tools ly amd-ucode xf86-input-libinput tlp tlp-rdw powertop acpi ntp neovim git man --noconfirm

# Habilitar servicios
systemctl enable ly.service
systemctl enable tlp
systemctl mask systemd-rfkill.service
systemctl mask systemd-rfkill.socket
systemctl enable fstrim.timer
systemctl enable ntpd
systemctl start ntpd
systemctl enable bluetooth
ntpd -qg

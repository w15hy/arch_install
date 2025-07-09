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
pacman -S xorg-server xorg-apps xorg-xinit kitty zsh fzf --noconfirm
pacman -S i3 --noconfirm
pacman -S noto-fonts ttf-ubuntu-font-family ttf-dejavu ttf-freefont --noconfirm
pacman -S ttf-liberation ttf-droid ttf-roboto terminus-font --noconfirm
pacman -S firefox --noconfirm
pacman -S bluez bluez-utils  --noconfirm
pacman -S python net-tools ly amd-ucode xf86-input-libinput acpi neovim git man --noconfirm

# Habilitar servicios
systemctl enable ly.service
systemctl enable bluetooth

chsh -s /bin/zsh w15hy
chsh -s /bin/zsh root

sed -i 's/x_cmd = \/usr\/bin\/X/x_cmd = \/usr\/bin\/X >\/dev\/null 2\>\&1/' /etc/ly/config.ini

reboot

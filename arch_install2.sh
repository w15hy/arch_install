#!/bin/sh

set -e 

su - w15hy <<PAS
xdg-user-dirs-update

mkdir Sources
cd Sources

git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si --noconfirm
PAS

pacman -S python net-tools ly amd-ucode xf86-input-libinput tlp tlp-rdw powertop acpi ntp

systemctl enable ly.service
systemctl enable tlp
systemctl mask systemd-rfkill.service
systemctl mask systemd-rfkill.socket
systemctl enable fstrim.timer
systemctl enable ntpd
systemctl start ntpd
systemctl enable bluetooth
ntpd -qg

# Sudoers
sed -i '0,/# %wheel/s//%wheel/' /etc/sudoers 

# Configuration de pacman
rm -r /etc/pacman.conf
mv ./resources/pacman.conf /etc/pacman.conf # poner /mnt en la version final
pacman -Syu --noconfirm

rm -r /etc/default/grub 
mv ./resources/grub /etc/grub  # poner /mnt en la version final

pacman -S net-tools ly amd-ucode xf86-input-libinput tlp tlp-rdw powertop acpi--noconfirm # quitar en la version final
systemctl enable ly.service
systemctl enable tlp # quitar en la version final
systemctl enable tlp-sleep # quitar en la version final
systemctl mask systemd-rfkill.service # quitar en la version final
systemctl mask systemd-rfkill.socket # quitar en la version final
systemctl enable fstrim.timer # quitar en la version final y ver que hace bien
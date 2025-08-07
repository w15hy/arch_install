set -e

yay -S proton-pass-bin --noconfirm
pacman -S pavucontrol locate pipewire pipewire-audio pipewire-alsa pipewire-pulse --noconfirm
pacman -S flameshot rofi --noconfirm
pacman -S pavucontrol pipewire-audio pipewire-alsa pipewire-pulse --noconfirm
pacman -S xf86-video-amdgpu --noconfirm
pacman -S 7zip acpi amd-ucode baobab feh flameshot gnome-themes-extra gvfs gvfs-mtp gvfs-nfs koodo-reader-bin lazygit mpd ncmpcpp npm obsidian packettracer pcmanfm picom polybar ttf-jetbrains-mono-nerd unzip xclip zip --noconfirm
pacman -S mesa lib32-mesa --noconfirm
pacman -S qemu-full qemu-img libvirt virt-install virt-manager virt-viewer edk2-ovmf dnsmasq swtpm guestfs-tools libosinfo tuned --noconfirm

rm -r /etc/ly/setup.sh
rm -r /etc/ly/config.ini

mv ./resources/config.ini ./resources/screen.sh ./resources/setup.sh /etc/ly/

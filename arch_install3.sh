set -e 

yay -S proton-pass-bin --noconfirm
pacman -S pavucontrol locate pipewire pipewire-audio pipewire-alsa pipewire-pulse --noconfirm
pacman -S flameshot rofi --noconfirm
pacman -S pavucontrol pipewire-audio pipewire-alsa pipewire-pulse --noconfirm
pacman -S xf86-video-amdgpu
pacman -S mesa lib32-mesa

mv ./resources/screen.sh ~/.config/ # a;adir esto al final del /etc/ly/setup.sh

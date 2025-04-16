#!/bin/sh

echo "--------------------------------------------------------------------------------------------------------"
echo "Instalation of Arch Linux"
echo "--------------------------------------------------------------------------------------------------------"

# Config
TARGET_DISK='/dev/sda'
# FONT='ter-132b'
TIMEZONE=$1 
HOSTNAME=$2
PASSWD=$3
PASSWDROOT=$4

if ! lsblk | grep -q "/mnt"; then
    umount /mnt /mnt/boot
    swapoff "$TARGET_DISK"2
fi

setfont "$FONT"
timedatectl set-timezone "$TIMEZONE"

# Limpiar disco por si hay algo antes -- Ojito con esto -- 
sgdisk --zap-all "$TARGET_DISK"
echo "--------------------------------------------------------------------------------------------------------"

# Disk
parted "$TARGET_DISK" mklabel gpt
echo "--------------------------------------------------------------------------------------------------------"

# Efi system
parted "$TARGET_DISK" mkpart primary fat32 1MiB 501MiB
parted "$TARGET_DISK" set 1 esp on 
echo "--------------------------------------------------------------------------------------------------------"

# Swap
parted "$TARGET_DISK" mkpart primary linux-swap 501MiB 8693MiB
echo "--------------------------------------------------------------------------------------------------------"

# Linux filesystem
parted "$TARGET_DISK" mkpart primary ext4 8693MiB 100%
echo "--------------------------------------------------------------------------------------------------------"

# Formatear particiones
mkfs.fat -F 32 "$TARGET_DISK"1
mkswap "$TARGET_DISK"2
mkfs.ext4 "$TARGET_DISK"3

# Montar particiones
mount "$TARGET_DISK"3 /mnt
mount --mkdir "$TARGET_DISK"1 /mnt/boot
swapon "$TARGET_DISK"2 

# Mirrorlist
pacman -Sy
pacman -S rsync --noconfirm
reflector --verbose --latest 10 --sort rate --save /etc/pacman.d/mirrorlist

# Instalar componentes basicos
pacstrap -K /mnt base base-devel linux-zen linux-zen-headers linux-firmware amd-ucode networkmanager xf86-input-libinput mkinitcpio

# Fstab
genfstab -p /mnt >> /mnt/etc/fstab

# Entrar al sistema montado
arch-chroot /mnt <<EOF

# Configurar zona horaria
ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
hwclock --systohc
timedatectl set-ntp true

# Instalar y habilitar NTP
pacman -S --noconfirm ntp
systemctl enable ntpd
systemctl start ntpd

# Configurar nombre de host
echo "${HOSTNAME}" > /etc/hostname

# Configurar /etc/hosts
cat <<HOSTS > /etc/hosts
127.0.0.1       localhost
::1             localhost
127.0.1.1       ${HOSTNAME}.localdomain ${HOSTNAME}
HOSTS

# Generar initramfs
mkinitcpio -P

# Sudoers
sed -i '0,/# %wheel/s//%wheel/' /etc/sudoers

# GRUB CONFIGURATION
pacman -S grub efibootmgr --noconfirm
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Arch --removable

sed -i '
s/^GRUB_TIMEOUT=5/# Configuration to not show the GRUB\nGRUB_TIMEOUT=0 # GRUB_TIMEOUT=5 was the original value/
 /GRUB_TIMEOUT=0/a\
GRUB_HIDDEN_TIMEOUT=0 # Comment if you dont want it\n' /etc/default/grub

grub-mkconfig -o /boot/grub/grub.cfg

# Enable networkmanager
systemctl enable NetworkManager

# Pacman configuration
sed -i 's/#Color/Color/' /etc/pacman.conf
sed -i '/Color/a\ILoveCandy' /etc/pacman.conf
sed -i 's/#VerbosePkgLists/VerbosePkgLists/' /etc/pacman.conf
sed -i 's/ParallelDownloads = 5/ParallelDownloads = 10/' /etc/pacman.conf
sed -i 's/#\[multilib\]/[multilib]/' /etc/pacman.conf

awk '
/^#Include = \/etc\/pacman.d\/mirrorlist/ {
    count++
    if (count == 4) {
        sub(/^#/, "")
    }
}
{ print }
' /etc/pacman.conf > tmp && mv tmp /etc/pacman.conf

pacman -S neovim net-tools ly xdg-user-dirs git --noconfirm
systemctl enable ly.service

pacman -S bluez bluez-utils blueman --noconfirm
systemctl enable bluetooth

pacman -S tlp tlp-rdw powertop acpi --noconfirm
systemctl enable tlp
systemctl enable tlp-sleep
systemctl mask systemd-rfkill.service
systemctl mask systemd-rfkill.socket

systemctl enable fstrim.timer

pacman -S xorg-server xorg-apps xorg-xinit --noconfirm
pacman -S i3-gaps i3blocks i3lock numlockx --noconfirm

pacman -S noto-fonts ttf-ubuntu-font-family ttf-dejavu ttf-freefont --noconfirm
pacman -S ttf-liberation ttf-droid ttf-roboto terminus-font --noconfirm
pacman -S firefox ----noconfirm

passwd root <<PAS
${PASSWDROOT}
${PASSWDROOT}
PAS

useradd -m -g users -G wheel,storage,power,audio w15hy
passwd w15hy <<PAS
${PASSWD}
${PASSWD}
PAS

su - w15hy <<PAS
${PASSWD}
PAS

xdg-user-dirs-update

mkdir Sources
cd Sources 

git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si




EOF

# # falta instalar bluez bluez-utils umount y pacman config


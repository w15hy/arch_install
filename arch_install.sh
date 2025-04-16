#!/bin/sh

set -e # Abortará el script si algún comando falla

echo "--------------------------------------------------------------------------------------------------------"
echo "Instalation of Arch Linux"
echo "--------------------------------------------------------------------------------------------------------"

# Configuración
TARGET_DISK='/dev/sda'
TIMEZONE=$1
HOSTNAME=$2

while [ -z "$PASSWD" ]
do
    read -s -p "Insert your password for user: " PASSWD;
    echo
done

while [ -z "$PASSWDROOT" ] 
do
    read -s -p "Insert your password for root: " PASSWDROOT;
    echo
done

if [ -z "$TIMEZONE" ] || [ -z "$HOSTNAME" ]; then
    echo "Faltan parámetros. Uso: $0 <TIMEZONE> <HOSTNAME>"
    exit 1
fi

# Limpiar disco
echo "Limpiando el disco..."
parted "$TARGET_DISK" mklabel gpt


# Crear particiones
parted "$TARGET_DISK" mkpart primary fat32 1MiB 501MiB
parted "$TARGET_DISK" set 1 esp on 
parted "$TARGET_DISK" mkpart primary linux-swap 501MiB 8693MiB
parted "$TARGET_DISK" mkpart primary ext4 8693MiB 100%

# Formatear particiones
mkfs.fat -F 32 "$TARGET_DISK"1
mkswap "$TARGET_DISK"2
mkfs.ext4 "$TARGET_DISK"3

# Montar particiones
mount "$TARGET_DISK"3 /mnt
mount --mkdir "$TARGET_DISK"1 /mnt/boot
swapon "$TARGET_DISK"2 

# Actualizar mirrorlist
pacman -Sy --noconfirm
pacman -S rsync --noconfirm
reflector --verbose --latest 10 --sort rate --save /etc/pacman.d/mirrorlist

# Instalar componentes basicos
pacstrap -K /mnt base base-devel linux-zen linux-zen-headers linux-firmware

# Fstab
genfstab -p /mnt >> /mnt/etc/fstab

# Entrar al sistema montado
arch-chroot /mnt <<EOF
ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
hwclock --systohc
timedatectl set-ntp true

# Configuracion de hostname y hosts
echo "${HOSTNAME}" > /etc/hostname

# Configurar /etc/hosts
sed 's/HOSTNAME/${HOSTNAME}' ./resources/hosts
rm -r /etc/hosts
mv ./resources/hosts /etc/hosts

# Generar initramfs
mkinitcpio -P

# GRUB
pacman -Syu --noconfirm
pacman -S grub efibootmgr xdg-user-dirs --noconfirm
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Arch --removable
grub-mkconfig -o /boot/grub/grub.cfg

# Habilitar networkmanager
pacman -Sy --noconfirm
pacman -S networkmanager
systemctl enable NetworkManager

# PASWORD ROOT AND USER 
passwd root <<PAS
${PASSWDROOT}
${PASSWDROOT}
PAS

useradd -m -g users -G wheel,storage,power,audio w15hy
passwd w15hy <<PAS
${PASSWD}
${PASSWD}
PAS

xdg-user-dirs-update

EOF

# # falta instalar bluez bluez-utils umount y pacman config

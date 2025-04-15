echo "--------------------------------------------------------------------------------------------------------"
echo "Instalation of Arch Linux"
echo "--------------------------------------------------------------------------------------------------------"


# Config
TARGET_DISK='/dev/sda'
# FONT='ter-132b'
TIMEZONE=$1 
HOSTNAME=$2
PASSWD=$3

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

pacman -S grub efibootmgr --noconfirm
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Arch --removable
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager

passwd root <<PAS
${PASSWD}
${PASSWD}
PAS

EOF

# # falta instalar neovim bluez bluez-utils


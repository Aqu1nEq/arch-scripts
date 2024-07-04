#!/usr/bin/env bash

COUNTRY=Bangladesh,India
REGION=Asia
CITY=Dhaka

clear

echo "--------------------------------------"
echo "----ARCH MINIMAL w/ NVIDIA----------"
echo "--------------------------------------"
echo "--------------------------------------"
echo "--------------------------------------"
echo " "

echo "The main Drive: (example /dev/sda or /dev/nvme0n1)"
read DRIVE

echo "Enter EFI paritition: (example /dev/sda1 or /dev/nvme0n1p1)"
read EFI

echo "Enter SWAP paritition: (example /dev/sda2)"
read SWAP

echo "Enter Root(/) paritition: (example /dev/sda3)"
read ROOT 

echo "Enter Home(/home) paritition: (example /dev/sda4)"
read HOME

echo "Enter your hostname"
read HOST 

echo "Enter your username"
read USER 

echo "Enter your password"
read PASSWORD 


# make filesystems
echo -e "\nCreating Filesystems...\n"

mkfs.fat -F 32 "${EFI}"
mkswap "${SWAP}"
swapon "${SWAP}"
mkfs.ext4 "${ROOT}"
mkfs.ext4 "${HOME}"

# mount target
mount "${ROOT}" /mnt
mount --mkdir "${EFI}" /mnt/boot/efi
mount --mkdir "${HOME}" /mnt/home

# mirrorlist
echo -e "\nGenerating Fastest Mirrorlist...\n"

cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
reflector --verbose --download-timeout 30 --latest 10 --country ${COUNTRY} --protocol http,https --sort rate --save /etc/pacman.d/mirrorlist

# configure pacaman

# pacman.conf:
# 33 -> #Color > Color
# 36 -> #VerbosePkgList > VerbosePkgList
# 37 -> #ParallelDownlads > ParallelDownlads
# 90 -> #[multilib] > [multilib]
# 91 -> #Include > Include
# 37 -> Add new line ILoveCandy
pacman -Sy

# Main Linux
echo "--------------------------------------"
echo "-- INSTALLING Arch Linux Minimal including GRUB on Main Drive       --"
echo "--------------------------------------"
# pacstrap -K /mnt base linux linux-firmware base-devel nano bash-completion grub efibootmgr networkmanager linux-headers --noconfirm --needed
pacstrap -K /mnt base linux  base-devel nano bash-completion grub efibootmgr networkmanager linux-headers --noconfirm --needed

# fstab
genfstab -U /mnt >> /mnt/etc/fstab

cat <<REALEND > /mnt/next.sh
useradd -m -g users -G wheel,storage,power -s /bin/bash ${USER}
echo $USER:$PASSWORD | chpasswd
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
sed -i '$a\Defaults rootpw' /etc/sudoers

echo "-------------------------------------------------"
echo "Setup Language to US and set locale"
echo "-------------------------------------------------"
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen

locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

ln -sf /usr/share/zoneinfo/${REGION}/${CITY} /etc/localtime
hwclock --systohc

echo "${HOST}" >> /etc/hostname

systemctl enable NetworkManager
systemctl enable fstrim.timer

# boot manager
grub-install ${DRIVE}
grub-mkconfig -o /boot/grub/grub.cfg


echo "You have to Install Desktop Yourself"

echo "-------------------------------------------------"
echo "Install Complete, You can reboot now"
echo "-------------------------------------------------"

REALEND

arch-chroot /mnt sh next.sh

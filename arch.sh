#!/usr/bin/env bash


REGION=$1
CITY=$2


echo "--------------------------------------"
echo "--------------------------------------"
echo "----------ARCH MINIMAL----------------"
echo "--------------------------------------"
echo "--------------------------------------"
echo "Press Ctrl + c to exit "
echo "NOTE: make sure to update your mirrorlist by running mirror.sh or edit by yourself"
echo " "


echo "Enter The main Drive: (example sda or nvme0n1)"
read DRIVE

echo "Enter EFI paritition: (example sda1 or nvme0n1p1)"
read EFI

echo "Enter SWAP paritition: (example sda2)"
read SWAP

echo "Enter Root(/) paritition: (example sda3)"
read ROOT 

echo "Enter Home(/home) paritition: (example sda4)"
read HOME

echo "Enter your hostname"
read HOST 

echo "Enter your username"
read USER 

echo "Enter your password"
read PASSWORD 


# make filesystems
echo "-------------------------------------------------"
echo -e "\nCreating Filesystems...\n"
echo "-------------------------------------------------"

mkfs.fat -F 32 /dev/${EFI}
mkswap /dev/${SWAP}
swapon /dev/${SWAP}
mkfs.ext4 -F /dev/${ROOT}
mkfs.ext4 -F /dev/${HOME}

# mount target
echo "-------------------------------------------------"
echo -e "\nMounting Targets...\n"
echo "-------------------------------------------------"
mount /dev/${ROOT} /mnt
mount --mkdir /dev/${EFI} /mnt/boot/efi
mount --mkdir /dev/${HOME} /mnt/home

# configure pacaman
echo "-------------------------------------------------"
echo -e "\Configuring Pacman...\n"
echo "-------------------------------------------------"

cp /etc/pacman.conf /etc/pacman.conf.backup

sed -i 's/^#Color/Color/' /etc/pacman.conf
sed -i 's/^#VerbosePkgList/VerbosePkgList/' /etc/pacman.conf
sed -i 's/^#ParallelDownloads =/ParallelDownloads =/' /etc/pacman.conf
sed -i '90s/.*/[multilib]/' /etc/pacman.conf
sed -i '91s/.*/Include = \/etc\/pacman\.d\/mirrorlist/' /etc/pacman.conf
sed -i '37a\ILoveCandy ' /etc/pacman.conf

pacman -Sy 

# Main Linux
echo "--------------------------------------"
echo "-- INSTALLING Arch Linux Minimal including GRUB on Main Drive------"
echo "--------------------------------------"
pacstrap -K /mnt base linux linux-firmware base-devel nano bash-completion grub efibootmgr networkmanager linux-headers --noconfirm --needed

# fstab
echo -e "\Generating fstab...\n"
genfstab -U /mnt >> /mnt/etc/fstab

cat <<REALEND > /mnt/next.sh
echo "-------------------------------------------------"
echo -e "Changing root password and adding new user...\n"
echo "-------------------------------------------------"
useradd -m -g users -G wheel,storage,power -s /bin/bash ${USER}
echo "root:$PASSWORD" | chpasswd
echo $USER:$PASSWORD | chpasswd
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

echo "-------------------------------------------------"
echo -e "Configuring Sudoers file...\n"
echo "-------------------------------------------------"
sed -i '\$a Defaults rootpw ' /etc/sudoers

echo "-------------------------------------------------"
echo "Setup Language to US and set locale"
echo "-------------------------------------------------"
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen

locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

ln -sf /usr/share/zoneinfo/${REGION}/${CITY} /etc/localtime
hwclock --systohc

echo "-------------------------------------------------"
echo -e "Setting Hostname...\n"
echo "-------------------------------------------------"
echo "${HOST}" >> /etc/hostname

echo "-------------------------------------------------"
echo -e "Enabling NetworkManager and fstrim...\n"
echo "-------------------------------------------------"
systemctl enable NetworkManager
systemctl enable fstrim.timer

echo "-------------------------------------------------"
echo -e "Configuring Pacman...\n"
echo "-------------------------------------------------"
cp /etc/pacman.conf /etc/pacman.conf.backup

sed -i 's/^#Color/Color/' /etc/pacman.conf
sed -i 's/^#VerbosePkgList/VerbosePkgList/' /etc/pacman.conf
sed -i 's/^#ParallelDownloads =/ParallelDownloads =/' /etc/pacman.conf
sed -i '90s/.*/[multilib]/' /etc/pacman.conf
sed -i '91s/.*/Include = \/etc\/pacman\.d\/mirrorlist/' /etc/pacman.conf
sed -i '37a\ILoveCandy ' /etc/pacman.conf

# boot manager
echo "-------------------------------------------------"
echo "Installing and setting up GRUB"
echo "-------------------------------------------------"
grub-install /dev/${DRIVE}
grub-mkconfig -o /boot/grub/grub.cfg

echo "-------------------------------------------------"
echo "You have to Install Desktop Yourself"
echo "-------------------------------------------------"

echo "-------------------------------------------------"
echo "Install Complete, You can reboot now"
echo "-------------------------------------------------"

REALEND

arch-chroot /mnt sh next.sh


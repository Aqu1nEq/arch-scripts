#!/usr/bin/env bash


REGION=Asia
CITY=Dhaka


echo "--------------------------------------"
echo "--------------------------------------"
echo "----------ARCH MINIMAL----------------"
echo "--------------------------------------"
echo "--------------------------------------"
echo " "
echo "NOTE: make sure to update your mirrorlist by running mirror.sh or edit by yourself"
echo " "


echo "Enter The main Drive: (example /dev/sda or nvme0n1)"
read DRIVE

echo "Enter EFI paritition: (example /sda1 or nvme0n1p1)"
read EFI

echo "Enter SWAP paritition: (example /sda2)"
read SWAP

echo "Enter Root(/) paritition: (example /sda3)"
read ROOT 

echo "Enter Home(/home) paritition: (example /sda4)"
read HOME

echo "Enter your hostname"
read HOST 

echo "Enter your username"
read USER 

echo "Enter your password"
read PASSWORD 


# make filesystems
echo -e "\nCreating Filesystems...\n"

mkfs.fat -F 32 ${EFI}
mkswap ${SWAP}
swapon ${SWAP}
mkfs.ext4 -F ${ROOT}
mkfs.ext4 -F ${HOME}

# mount target
echo -e "\nMounting Targets...\n"
mount ${ROOT} /mnt
mount --mkdir ${EFI} /mnt/boot/efi
mount --mkdir ${HOME} /mnt/home

# configure pacaman
echo -e "\Configuring Pacman...\n"

cp /etc/pacman.conf /etc/pacman.conf.backup

sed -i 's/^#Color/Color/' /etc/pacman.conf
sed -i 's/^#VerbosePkgList/VerbosePkgList/' /etc/pacman.conf
sed -i 's/^#ParallelDownlads/ParallelDownlads/' /etc/pacman.conf
sed -i '90s/.*/[multilib]/' /etc/pacman.conf
sed -i '91s/.*/Include = \/etc\/pacman\.d\/mirrorlist/' /etc/pacman.conf
sed -i '37a\ILoveCandy' /etc/pacman.conf

pacman -Sy

# Main Linux
echo "--------------------------------------"
echo "-- INSTALLING Arch Linux Minimal including GRUB on Main Drive------"
echo "--------------------------------------"
# pacstrap -K /mnt base linux linux-firmware base-devel nano bash-completion grub efibootmgr networkmanager linux-headers --noconfirm --needed
pacstrap -K /mnt base linux  base-devel nano bash-completion grub efibootmgr networkmanager linux-headers --noconfirm --needed

# fstab
echo -e "\Generating fstab...\n"
genfstab -U /mnt >> /mnt/etc/fstab

cat <<REALEND > /mnt/next.sh
echo -e "\Changing root password and adding new user...\n"
useradd -m -g users -G wheel,storage,power -s /bin/bash ${USER}
echo "root:$PASSWORD" | chpasswd
echo $USER:$PASSWORD | chpasswd
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

echo -e "\Configuring Sudoers file...\n"
sed -i '$a\Defaults rootpw/' /etc/sudoers

echo "-------------------------------------------------"
echo "Setup Language to US and set locale"
echo "-------------------------------------------------"
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen

locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

ln -sf /usr/share/zoneinfo/${REGION}/${CITY} /etc/localtime
hwclock --systohc

echo -e "\Setting Hostname...\n"
echo "${HOST}" >> /etc/hostname

echo -e "\Enabling Networkmanager and fstrim...\n"
systemctl enable NetworkManager
systemctl enable fstrim.timer

echo -e "\Configuring Pacman...\n"
cp /etc/pacman.conf /etc/pacman.conf.backup

sed -i 's/^#Color/Color/' /etc/pacman.conf
sed -i 's/^#VerbosePkgList/VerbosePkgList/' /etc/pacman.conf
sed -i 's/^#ParallelDownlads/ParallelDownlads/' /etc/pacman.conf
sed -i '90s/.*/[multilib]/' /etc/pacman.conf
sed -i '91s/.*/Include = \/etc\/pacman\.d\/mirrorlist/' /etc/pacman.conf
sed -i '37a\ILoveCandy/' /etc/pacman.conf

# boot manager
echo "-------------------------------------------------"
echo "Installing and setting yp GRUB"
echo "-------------------------------------------------"
grub-install ${DRIVE}
grub-mkconfig -o /boot/grub/grub.cfg


echo "You have to Install Desktop Yourself"

echo "-------------------------------------------------"
echo "Install Complete, You can reboot now"
echo "-------------------------------------------------"

REALEND

arch-chroot /mnt sh next.sh

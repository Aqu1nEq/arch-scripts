pacman -S Install nvidia-dkms libglvnd nvidia-utils opencl-nvidia lib32-libglvnd lib32-nvidia-utils lib32-opencl-nvidia nvidia-settings vulkan-icd-loader lib32-vulkan-icd-loader --noconfirm --needed

# Remove kms from the HOOKS array in /etc/mkinitcpio.conf and regenerate the initramfs.

# nvidia_drm.modeset=1 in  /etc/default/grub
# replace line 7 with GRUB_CMDLINE_LINUX="quiet splash nvidia_drm.modeset=1 nvidia_drm.fbdev=1"
sed -i '7s/.*/GRUB_CMDLINE_LINUX="quiet splash nvidia_drm.modeset=1 nvidia_drm.fbdev=1"/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# in /etc/mkinitcpio.conf remove kms from line number 55
sed -i '55s/^kms / /' /etc/mkinitcpio.conf

# MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)
# line no.7
sed -i '7s/.*/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf

mkinitcpio -P

# Hooks
mkdir -p /etc/pacman.d/hooks/pacman.d/hooks

cat <<REALEND > /etc/pacman.d/hooks/nvidia.hook

[Trigger]
Operation=Install
Operation=Upgrade
Operation=Remove
Type=Package
# Uncomment the installed NVIDIA package
Target=nvidia-dkms

[Action]
Description=Updating NVIDIA module in initcpio
Depends=mkinitcpio
When=PostTransaction
Exec=/usr/bin/mkinitcpio -P

REALEND
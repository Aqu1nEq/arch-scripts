# Arch Made Easy
`My custom scripts for arch linux`

Arch is a great distro. But setting it up can be a bit of a pain. So,
## This repo contains scripts that can be used to automate that process with no bloat with a minimalistic approach. 

# Getting Started
## `Post Setup`
-  **Boot into your arch iso and be sure that you are in UEFI mode**
- **Verify boot mode:** `cat /sys/firmware/efi/fw_platform_size` should return 64 
- - **Connect to the internet:** `ping 1.1.1.1` should respond otherwise, use USB tether from you phone
- **Partition:** `lsblk`, then `cfdisk`. Delete partition or create new one from here.

| Mount point on the installed system | Partition                    | Partition type                                   | Suggested size                    |
|------------------------------------|------------------------------|--------------------------------------------------|-----------------------------------|
| `/boot`          | `/dev/efi_system_partition` | [EFI system partition](https://en.wikipedia.org/wiki/GUID_Partition_Table#Partition_type_GUIDs) | 1 GiB                             |
| `[SWAP]`                           | `/dev/swap_partition` | Linux swap                                       | At least 4 GiB                     |
| `/`                                | `/dev/root_partition` | Linux x86-64 root (/)                            | Remainder of the device. At least 23–32 GiB. |


- Create a separate partition for home directory is optional.
- Use curl to get the mirror.sh script and run it.
  `curl -O https://raw.githubusercontent.com/Aqu1nEq/arch-scripts/main/mirror.sh`
  `chmod +x mirror.sh`
- Execute `mirror.sh` by running:
```
./mirror.sh [nearest country] [another nearest country]
```
Exmaple : `./mirror.sh US Canada`

## `Installation`
- Use curl to get the arch.sh script and run it.
  `curl -O https://raw.githubusercontent.com/Aqu1nEq/arch-scripts/main/arch.sh`
  `chmod +x arch.sh`
- Execute `arch.sh` by running: (Region & City are used to configure local time. more zoneinfo: [zoneinfo][https://archlinux.org/packages/core/x86_64/tzdata/files/])
```
./arch.sh [REGION] [City]
```
Exmaple : `./arch.sh Asia Dhaka`
- Follow the instructions from there

# Nvidia Script
After Installing arch, Reboot

and just ```curl -O https://raw.githubusercontent.com/Aqu1nEq/arch-scripts/testing/nvidia.sh```
and ```chmod +x nvidia.sh``` then ```sudo ./nvidia.sh```

**Any contribution is welcomed** 😊

--**aqu1neq**--

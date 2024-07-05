#!/usr/bin/env bash

COUNTRY=$1,$2

# mirrorlist
echo -e "\nGenerating Fastest Mirrorlist...\n"

cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
reflector --verbose --download-timeout 30 --latest 10 --country ${COUNTRY} --protocol http,https --sort rate --save /etc/pacman.d/mirrorlist
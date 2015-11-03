#!/bin/bash

DIR=$(dirname "$(readlink -f "$0")")

source $DIR/utils.sh

ROOT_MOUNT="/mnt/gentoo"
BOOT_EFI_DIR="/EFI/GENTOO"
GIT_REPO="https://github.com/zszafran/gentoo-mba-dotfiles.git"
REPO_DIR="$ROOT_MOUNT/repo"
STAGE3_VERSION="20151029"

echo -e "\nSelect ROOT device:\n"
ROOT_DEVICE=$(select_device_uuid)

echo -e "\nSelect BOOT device:\n"
BOOT_DEVICE=$(select_device_uuid)

mount_root $ROOT_DEVICE $ROOT_MOUNT
mount_eti_boot $BOOT_DEVICE $ROOT_MOUNT $BOOT_EFI_DIR
mount_cdrom $ROOT_MOUNT

git_init_repo $REPO_DIR $ROOT_MOUNT $GIT_REPO
git_config_ignore $REPO_DIR

install_stage3 $STAGE3_VERSION $ROOT_MOUNT

mount_devices $ROOT_MOUNT

chroot $ROOT_MOUNT /bin/bash -x $DIR/stage3-restore.sh

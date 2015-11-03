#!/bin/bash

function status_update() {
  RESET="\e[0m"
  YELLOW="\e[33m"
  echo -e "\n[${YELLOW}*${RESET}] ${YELLOW}$1${RESET}\n"
}

function mount_root() {
  status_update "Mounting Root"
  mount "UUID=$1" $2
}

function mount_efi_boot() {
  status_update "Mounting EFI Boot"
  mkdir -p $2/mnt/efi
  mkdir -p $2/boot
  mount "UUID=$1" $2/mnt/efi
  mount --rbind $2/mnt/efi/$3 $1/boot
}

function mount_cdrom() {
  status_update "mounting CD ROM"
  mkdir -p $1/mnt/cdrom
  mount --rbind /mnt/cdrom $1/mnt/cdrom
}

function make_default_dirs() {
  status_update "Creating default directories"
  mkdir -p $1/usr/portage
}

function git_init_repo() {
  status_update "Initializing GIT Repo"
  mkdir -p $1
  git --git-dir=$1 init
  git --git-dir=$1 remote add origin $3
  git --git-dir=$1 --work-tree=$2 fetch
  git --git-dir=$1 --work-tree=$2 checkout --force -t origin/master
}

function git_config_ignore() {
  status_update "Configuring GIT Repo"
  echo "*" > $1/.gitignore
}

function git_fetch() {
  status_update "Fetching GIT Repo"
  git --git-dir=$1 --work-tree=$2 checkout --force
}

function install_stage3() {
  status_update "Installing Stage3"
  wget http://distfiles.gentoo.org/releases/amd64/autobuilds/${1}/stage3-amd64-${1}.tar.bz2 -O $2/stage3.tar.bz2
  tar xvjkf $2/stage3.tar.bz2 -C $2 || true
  rm $2/stage3.tar.bz2
}

function mount_devices() {
  status_update "Mounting Devices"
  mount -t proc proc $1/proc
  mount --rbind /sys $1/sys
  mount --make-rslave $1/sys
  mount --rbind /dev $1/dev
  mount --make-rslave $1/dev
}

function update_env() {
  status_update "Updating Env"
  env-update
  source /etc/profile
}

function emerge_utils() {
  status_message "Installing Utils"
  emerge --sync
  emerge --oneshot gcc
  gcc-config $1
  source /etc/profile
  emerge --oneshot binutils glibc
  emerge --oneshot portage gentoolkit
  emerge --update --nodeps udev-init-scripts procps
  emerge --update shadow openrc udev
}

function emerge_system() {
  status_message "Installing System"
  sh /usr/portage/scripts/bootstrap.sh
  emerge -e eyetem
}

function emerge_kernel() {
  status_message "Installing Kernel"
  emerge sys-kernel/gentoo-sources
}

function build_kernel() {
  status_message "Building Kernel"
  cd /usr/src/linux
  make olddefconfig
  make modules_prepare
  emerge @modules-rebuid
  make
  make modules_install
  make install
}

function update_scripting() {
  status_message "Updating Scripting Libraries"
  perl-cleaner --reallyall
  python-updater
}

function emerge_world() {
  status_update "Installing World"
  cat /var/lib/portage/world | xargs -n1 emerge -uv
  emerge -avDn @world
}

function emerge_repair() {
  status_update "Repairing Packages"
  revdep-rebuild
  emaint --fix
}

function select_device_uuid() {
  IFS=$'\n'; set -f; devices=($(blkid))

  select opt in "${devices[@]}"
  do
    echo $opt | grep -Po '(?<= UUID=")[^"]*'
    break
  done
}

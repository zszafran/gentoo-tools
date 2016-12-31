#!/bin/bash

DIR=$(dirname "$(readlink -f "$0")")

source $DIR/utils.sh

ROOT_MOUNT="/"
REPO_DIR="/repo"
NEW_GCC="x86_64-gentoo-linux-gnu-5.4.0"

update_env

emerge_utils $NEW_GCC

emerge_system

emerge_kernel

# Make sure kernel .config is updated
git_checkout $REPO_DIR $ROOT_MOUNT

build_kernel

update_scripting

emerge_world

# Make sure all configs are restored
git_checkout $REPO_DIR $ROOT_MOUNT

emerge_repair

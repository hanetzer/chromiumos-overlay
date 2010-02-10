#!/bin/bash

# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Script to build a bootable keyfob-based chromeos system image from within
# a chromiumos setup. This assumes that all needed packages have been built into
# the given target's root with binary packages turned on. This script will
# build the Chrome OS image using only pre-built binary packages.
#
# NOTE: This script must be run from the chromeos build chroot environment.
#

# Load common constants.  This should be the first executable line.
# The path to common.sh should be relative to your script's location.
. "$(dirname "$0")/common.sh"

# Script must be run inside the chroot
assert_inside_chroot

# Flags
DEFINE_string board "" \
  "The board to build an image for."
DEFINE_string board_root "/build" \
  "The root location for board sysroots."
DEFINE_integer build_attempt 1                                \
  "The build attempt for this image build."
DEFINE_string output_root "${DEFAULT_BUILD_ROOT}/images"      \
  "Directory in which to place image result directories (named by version)"
DEFINE_string build_root "$DEFAULT_BUILD_ROOT"                \
  "Root of build output"
DEFINE_boolean replace $FLAGS_FALSE \
  "Overwrite existing output, if any."
DEFINE_boolean withdev $FLAGS_TRUE \
  "Include useful developer friendly utilities in the image."
DEFINE_boolean installmask $FLAGS_TRUE \
  "Use INSTALL_MASK to shrink the resulting image."
DEFINE_integer jobs -1 \
  "How many packages to build in parallel at maximum."

# DEPRECATED
DEFINE_string target "DEPRECATED" \
  "This flag is deprecated and should be removed when buildbots are updated."


# Parse command line
FLAGS "$@" || exit 1
eval set -- "${FLAGS_ARGV}"

# Die on any errors.
set -e

if [ -z "$FLAGS_board" ] ; then
  echo "Error: --board is required."
  exit 1
fi

# Determine build version
. "${SCRIPTS_DIR}/chromeos_version.sh"

# Use canonical path since some tools (e.g. mount) do not like symlinks
# Append build attempt to output directory
IMAGE_SUBDIR="${CHROMEOS_VERSION_STRING}-a${FLAGS_build_attempt}"
OUTPUT_DIR="${FLAGS_output_root}/${FLAGS_board}/${IMAGE_SUBDIR}"
ROOT_FS_DIR="${OUTPUT_DIR}/rootfs"
ROOT_FS_IMG="${OUTPUT_DIR}/rootfs.image"
MBR_IMG="${OUTPUT_DIR}/mbr.image"
OUTPUT_IMG="${OUTPUT_DIR}/usb.img"

BOARD="${FLAGS_board}"
BOARD_DIR="${FLAGS_board_root}/${BOARD}"

LOOP_DEV=

# What cross-build are we targeting?
. "${BOARD_DIR}/etc/make.conf.board_setup"
LIBC_VERSION=${LIBC_VERSION:-"2.10.1-r1"}

# Figure out ARCH from the given toolchain
# TODO: Move to common.sh as a function after scripts are switched over.
TC_ARCH=$(echo "$CHOST" | awk -F'-' '{ print $1 }')
case "$TC_ARCH" in
  arm*)
    ARCH="arm"
    ;;
  *86)
    ARCH="x86"
    ;;
  *)
    echo "Error: Unable to determine ARCH from toolchain: $CHOST"
    exit 1
esac

# Hack to fix bug where x86_64 CHOST line gets incorrectly added
# ToDo(msb): remove this hack
PACKAGES_FILE="${BOARD_DIR}/packages/Packages"
sudo sed -e "s/CHOST: x86_64-pc-linux-gnu//" -i "${PACKAGES_FILE}"

# Handle existing directory
if [[ -e "$OUTPUT_DIR" ]]; then
  if [[ $FLAGS_replace -eq $FLAGS_TRUE ]]; then
    sudo rm -rf "$OUTPUT_DIR"
  else
    echo "Directory $OUTPUT_DIR already exists."
    echo "Use --build_attempt option to specify an unused attempt."
    echo "Or use --replace if you want to overwrite this directory."
    exit 1
  fi
fi

# create the output directory
mkdir -p "$OUTPUT_DIR"

cleanup_rootfs_loop() {
  sudo umount "$LOOP_DEV"
  sleep 1  # in case $LOOP_DEV is in use (TODO: Try umount -l?)
  sudo losetup -d "$LOOP_DEV"
}

cleanup() {
  # Disable die on error.
  set +e

  if [[ -n "$LOOP_DEV" ]]; then
    cleanup_rootfs_loop
  fi

  # Turn die on error back on.
  set -e
}
trap cleanup EXIT

mkdir -p "$ROOT_FS_DIR"

# -- Create and format the root file system --

# Create root file system disk image to fit on a 1GB memory stick.
# 1 GB in hard-drive-manufacturer-speak is 10^9, not 2^30.  950MB < 10^9 bytes.
ROOT_SIZE_BYTES=$((1024 * 1024 * 512))
dd if=/dev/zero of="$ROOT_FS_IMG" bs=1 count=1 seek=$((ROOT_SIZE_BYTES - 1))

# Format, tune, and mount the rootfs.
UUID=$(uuidgen)
DISK_LABEL="C-KEYFOB"
LOOP_DEV=$(sudo losetup -f)
sudo losetup "$LOOP_DEV" "$ROOT_FS_IMG"
sudo mkfs.ext3 "$LOOP_DEV"
sudo tune2fs -L "$DISK_LABEL" -U "$UUID" -c 0 -i 0 "$LOOP_DEV"
sudo mount "$LOOP_DEV" "$ROOT_FS_DIR"

# -- Turn root file system into bootable image --
if [[ "$ARCH" = "x86" ]]; then
  # Setup extlinux configuration.
  # TODO: For some reason the /dev/disk/by-uuid is not being generated by udev
  # in the initramfs. When we figure that out, switch to root=UUID=$UUID.
  sudo mkdir -p "$ROOT_FS_DIR"/boot
  # TODO(adlr): use initramfs for booting
  cat <<EOF | sudo dd of="$ROOT_FS_DIR"/boot/extlinux.conf
DEFAULT chromeos-usb
PROMPT 0
TIMEOUT 0

label chromeos-usb
  menu label chromeos-usb
  kernel vmlinuz
  append quiet console=tty2 init=/sbin/init boot=local rootwait root=/dev/sdb3 ro noresume noswap i915.modeset=1 loglevel=1

label chromeos-hd
  menu label chromeos-hd
  kernel vmlinuz
  append quiet console=tty2 init=/sbin/init boot=local rootwait root=HDROOT ro noresume noswap i915.modeset=1 loglevel=1
EOF

  # Make partition bootable and label it.
  sudo extlinux -z --install "${ROOT_FS_DIR}/boot"
fi

# -- Install packages into the root file system --

# We need to install libc manually from the cross toolchain.
# TODO: Improve this? We only want libc and not the whole toolchain.
PKGDIR="/var/lib/portage/pkgs/cross/"
sudo tar jxvpf \
  "${PKGDIR}/${CHOST}/cross-${CHOST}"/glibc-${LIBC_VERSION}.tbz2 \
  -C "$ROOT_FS_DIR" --strip-components=3 \
  --exclude=usr/include --exclude=sys-include --exclude=*.a --exclude=*.o

# We need to install libstdc++ manually from the cross toolchain.
# TODO: Figure out a better way of doing this?
sudo cp -a /usr/lib/gcc/"${CHOST}"/*/libgcc_s.so* "${ROOT_FS_DIR}/lib"
sudo cp -a /usr/lib/gcc/"${CHOST}"/*/libstdc++.so* "${ROOT_FS_DIR}/usr/lib"

INSTALL_MASK=""
if [[ $FLAGS_installmask -eq $FLAGS_TRUE ]] ; then
  INSTALL_MASK="/usr/include/ /usr/man /usr/share/man /usr/share/doc /usr/share/gtk-doc /usr/share/gtk-2.0 /usr/lib/gtk-2.0/include /usr/share/info /usr/share/aclocal /usr/lib/gcc /usr/lib/pkgconfig /usr/share/pkgconfig /usr/share/gettext /usr/share/readline /usr/share/themes /etc/runlevels /usr/share/openrc /lib/rc *.a *.la"
fi

if [[ $FLAGS_jobs -ne -1 ]]; then
  EMERGE_JOBS="--jobs=$FLAGS_jobs"
fi

# We "emerge --root=$ROOT_FS_DIR --usepkgonly" all of the runtime
# packages for chrome os. This builds up a chrome os image. We'll use
# INSTALL_MASK and other tricks to trim the size as much as possible.
# Ex: INSTALL_MASK=" *.a *.la /usr/include/ /usr/lib/gcc /usr/share/doc /usr/share/gtk-doc /usr/share/info /usr/share/man"
# TODO: Whatever fanciness we can to reduce image size. Also uncomment when
# ready!
sudo INSTALL_MASK="$INSTALL_MASK" emerge-${BOARD} \
  --root="$ROOT_FS_DIR" --usepkgonly chromeos $EMERGE_JOBS
if [[ $FLAGS_withdev -eq $FLAGS_TRUE ]]; then
  sudo INSTALL_MASK="$INSTALL_MASK" emerge-${BOARD} \
    --root="$ROOT_FS_DIR" --usepkgonly chromeos-dev $EMERGE_JOBS

  # The ldd tool is a useful shell script but lives in glibc; just copy it.
  sudo cp -a "$(which ldd)" "${ROOT_FS_DIR}/usr/bin"
fi

# Perform any customizations on the root file system that are needed.
WITH_DEV=""
if [[ $FLAGS_withdev -eq $FLAGS_TRUE ]]; then
  WITH_DEV="--withdev"
fi
"${SCRIPTS_DIR}/new_customize_rootfs.sh" \
  --root="$ROOT_FS_DIR" \
  --target="$ARCH" \
  $WITH_DEV

cleanup_rootfs_loop

# Create a master boot record.
# Start with the syslinux master boot record. We need to zero-pad to
# fill out a 512-byte sector size.
SYSLINUX_MBR="/usr/share/syslinux/mbr.bin"
dd if="$SYSLINUX_MBR" of="$MBR_IMG" bs=512 count=1 conv=sync
# Create a partition table in the MBR.
NUM_SECTORS=$((`stat --format="%s" "$ROOT_FS_IMG"` / 512))
sudo sfdisk -H64 -S32 -uS -f "$MBR_IMG" <<EOF
,$NUM_SECTORS,L,-,
,$NUM_SECTORS,S,-,
,$NUM_SECTORS,L,*,
;
EOF

OUTSIDE_OUTPUT_DIR="~/chromeos/src/build/images/${IMAGE_SUBDIR}"
echo "Done.  Image created in ${OUTPUT_DIR}"
echo "To copy to USB keyfob, outside the chroot, do something like:"
echo "  ./image_to_usb.sh --from=${OUTSIDE_OUTPUT_DIR} --to=/dev/sdb"
echo "To convert to VMWare image, outside the chroot, do something like:"
echo "  ./image_to_vmware.sh --from=${OUTSIDE_OUTPUT_DIR}"

trap - EXIT

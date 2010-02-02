#!/bin/bash

# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# This script sets up a Gentoo chroot environment. The script is passed the
# path to an empty folder, which will be populated with a Gentoo stage3 and
# setup for development. Once created, the password is set to PASSWORD (below).
# One can enter the chrooted environment for work by running enter_chroot.sh.

# Load common constants.  This should be the first executable line.
# The path to common.sh should be relative to your script's location.
. "$(dirname "$0")/common.sh"

# Script must be run outside the chroot
assert_outside_chroot

# Define command line flags
# See http://code.google.com/p/shflags/wiki/Documentation10x

DEFINE_string chroot "$DEFAULT_CHROOT_DIR" \
  "Destination dir for the chroot environment."
DEFINE_boolean usepkg $FLAGS_TRUE "Use binary packages to bootstrap."
DEFINE_boolean delete $FLAGS_FALSE "Delete an existing chroot."
DEFINE_boolean replace $FLAGS_FALSE "Overwrite existing chroot, if any."
DEFINE_integer jobs -1 "How many packages to build in parallel at maximum."

# Parse command line flags
FLAGS "$@" || exit 1
eval set -- "${FLAGS_ARGV}"

# Only now can we die on error.  shflags functions leak non-zero error codes,
# so will die prematurely if 'set -e' is specified before now.
# TODO: replace shflags with something less error-prone, or contribute a fix.
set -e

FULLNAME="ChromeOS Developer"
DEFGROUPS="eng,adm,cdrom,floppy,audio,video,portage"
PASSWORD=chronos
CRYPTED_PASSWD=$(perl -e 'print crypt($ARGV[0], "foo")', $PASSWORD)

USEPKG=""
if [[ $FLAGS_usepkg -eq $FLAGS_TRUE ]]; then
  USEPKG="--getbinpkg --usepkg"
fi


function in_chroot {
  sudo chroot "$FLAGS_chroot" "$@"
}

function bash_chroot {
  # Use $* not $@ since 'bash -c' needs a single arg
  # Use -l to force source of /etc/profile (login shell)
  sudo chroot "$FLAGS_chroot" bash -l -c "$*"
}

function cleanup {
  # Clean up mounts
  mount | grep "on $(readlink -f "$FLAGS_chroot")" | awk '{print $3}' \
    | xargs -r -L1 sudo umount
}

function delete_existing {
  # Delete old chroot dir
  if [[ -e "$FLAGS_chroot" ]]; then
    echo "Cleaning up old mount points..."
    cleanup
    echo "Deleting $FLAGS_chroot..."
    sudo rm -rf "$FLAGS_chroot"
  fi
}

# Handle deleting an existing environment
if [[ $FLAGS_delete -eq $FLAGS_TRUE ]]; then
  delete_existing
  echo "Done."
  exit 0
fi

# Handle existing directory
if [[ -e "$FLAGS_chroot" ]]; then
  if [[ $FLAGS_replace -eq $FLAGS_TRUE ]]; then
    delete_existing
  else
    echo "Directory $FLAGS_chroot already exists."
    echo "Use --replace if you really want to overwrite it."
    exit 1
  fi
fi

CHROOT_TRUNK="${CHROOT_TRUNK_DIR}"
PORTAGE="${SRC_ROOT}/third_party/portage"
OVERLAY="${SRC_ROOT}/third_party/chromiumos-overlay"
CONFIG_DIR="${OVERLAY}/chromeos/config"
CHROOT_CONFIG="${CHROOT_TRUNK}/src/third_party/chromiumos-overlay/chromeos/config"
CHROOT_OVERLAY="/usr/local/portage/chromiumos"

# Create the destination directory
mkdir -p "$FLAGS_chroot"

# Create the base Gentoo stage3
STAGE3="${OVERLAY}/chromeos/stage3/stage3-amd64-2009.10.09.tar.bz2"
echo "Unpacking stage3..."
sudo tar xjp -C "$FLAGS_chroot" -f "$STAGE3"

# Add ourselves as a user inside the chroot
in_chroot groupadd -g 5000 eng
in_chroot useradd -G ${DEFGROUPS} -g eng -u `id -u` -s \
  /bin/bash -m -c "${FULLNAME}" -p ${CRYPTED_PASSWD} ${USER}

# Set up necessary mounts and make sure we clean them up on exit
trap cleanup EXIT
sudo mkdir -p "${FLAGS_chroot}/${CHROOT_TRUNK}"
sudo mount --bind "${GCLIENT_ROOT}" "${FLAGS_chroot}/${CHROOT_TRUNK}"
sudo mount none -t proc "$FLAGS_chroot/proc"
sudo mount none -t devpts "$FLAGS_chroot/dev/pts"
sudo mkdir -p "${FLAGS_chroot}/usr"
sudo ln -sf "${CHROOT_TRUNK}/src/third_party/portage" \
  "${FLAGS_chroot}/usr/portage"
sudo mkdir -p "${FLAGS_chroot}/usr/local/portage"
sudo ln -sf "${CHROOT_TRUNK}/src/third_party/chromiumos-overlay" \
  "${FLAGS_chroot}"/"${CHROOT_OVERLAY}"

# Some operations need an mtab
in_chroot ln -s /proc/mounts /etc/mtab

# Set up sudoers.  Inside the chroot, the user can sudo without a password.
# (Safe enough, since the only way into the chroot is to 'sudo chroot', so
# the user's already typed in one sudo password...)
bash_chroot "echo %adm ALL=\(ALL\) ALL >> /etc/sudoers"
bash_chroot "echo $USER ALL=NOPASSWD: ALL >> /etc/sudoers"
bash_chroot chmod 0440 /etc/sudoers

# Copy config from outside chroot into chroot
sudo cp /etc/hosts "$FLAGS_chroot/etc/hosts"
sudo chmod 0644 "$FLAGS_chroot/etc/hosts"
sudo cp /etc/resolv.conf "$FLAGS_chroot/etc/resolv.conf"
sudo chmod 0644 "$FLAGS_chroot/etc/resolv.conf"

# Setup host make.conf. This includes any overlay that we may be using
# and a pointer to pre-built packages.
# TODO: This should really be part of a profile in the portage
sudo mv "${FLAGS_chroot}"/etc/make.conf{,.orig}
sudo ln -sf "${CHROOT_CONFIG}/make.conf.amd64-host" \
  "${FLAGS_chroot}/etc/make.conf"
sudo mv "${FLAGS_chroot}"/etc/make.profile{,.orig}
sudo ln -sf "${CHROOT_OVERLAY}/profiles/default/linux/amd64/10.0" \
  "${FLAGS_chroot}/etc/make.profile"

# Create directories referred to by our conf files.
sudo mkdir -p "${FLAGS_chroot}/var/lib/portage/distfiles"
sudo mkdir -p "${FLAGS_chroot}/var/lib/portage/pkgs"

if [[ $FLAGS_jobs -ne -1 ]]; then
  EMERGE_JOBS="--jobs=$FLAGS_jobs"
fi

# Configure basic stuff needed
in_chroot env-update
bash_chroot ls -l /etc/make.conf
bash_chroot ls -l /etc/make.profile
bash_chroot ls -l /usr/local/portage/chromiumos/profiles/default/linux/amd64/10.0
bash_chroot emerge -v $USEPKG crossdev crossdev-wrappers sudo #ToDo(msb): remove this hack
#ToDo(msb): bash_chroot emerge -uDNv $USEPKG world $EMERGE_JOBS
#ToDo(msb): bash_chroot emerge -uDNv $USEPKG chromeos-base/hard-host-depends $EMERGE_JOBS

# Niceties for interactive logins ('enter_chroot.sh'); these are ignored
# when specifying a command to enter_chroot.sh.
# Warn less when apt-get installing packqages
echo "export LANG=C" >> "$FLAGS_chroot/home/$USER/.bashrc"
echo "export PS1=\"(gentoo) \$PS1\"" >> "$FLAGS_chroot/home/$USER/.bashrc"
chmod a+x "$FLAGS_chroot/home/$USER/.bashrc"
# Automatically change to scripts directory
echo "cd trunk/src/scripts" >> "$FLAGS_chroot/home/$USER/.profile"

# Warn if attempting to use source control commands inside the chroot
for NOUSE in svn gcl gclient
do
  echo "alias $NOUSE='echo In the chroot, it is a bad idea to run $NOUSE'" \
    >> "$FLAGS_chroot/home/$USER/.profile"
done

# Set up cross compilers for arm and x86
# TODO: If possible, nail down specific versions to use for each target arch.
BINHOST="http://www.corp.google.com/~tedbo/no_crawl/chronos/prebuilt/host/"
CROSS_X86_TARGET="i686-pc-linux-gnu"
CROSS_ARM_TARGET="armv7a-softfloat-linux-gnueabi"
CROSS_X86_BINHOST="${BINHOST}/cross/${CROSS_X86_TARGET}/"
CROSS_ARM_BINHOST="${BINHOST}/cross/${CROSS_ARM_TARGET}/"
CROSS_BINUTILS="--binutils 2.19.1-r1"
CROSS_GCC="--gcc 4.4.1"
CROSS_KERNEL="--kernel 2.6.30-r1"
CROSS_LIBC="--libc 2.10.1-r1"
CROSS_USEPKG=""
if [[ -n "$USEPKG" ]]; then
  CROSS_USEPKG="--portage --getbinpkg --portage --usepkgonly"
fi

bash_chroot crossdev \
  --target $CROSS_X86_TARGET \
  $CROSS_BINUTILS \
  $CROSS_GCC      \
  $CROSS_KERNEL   \
  $CROSS_LIBC     \
  $CROSS_USEPKG
bash_chroot crossdev \
  --target $CROSS_ARM_TARGET \
  $CROSS_BINUTILS \
  $CROSS_GCC      \
  $CROSS_KERNEL   \
  $CROSS_LIBC     \
  $CROSS_USEPKG
bash_chroot emerge-wrapper --init

# tell portage that glic is already built
# TODO: this is a hack and should really be done in crossdev-wrappers
PROFILE_DIR="${FLAGS_chroot}/usr/${CROSS_X86_TARGET}/etc/portage/profile"
sudo mkdir -p "${PROFILE_DIR}"
sudo bash -c "echo sys-libs/glibc-2.10.1-r1 > ""${PROFILE_DIR}""/package.provided"
PROFILE_DIR="${FLAGS_chroot}/usr/${CROSS_ARM_TARGET}/etc/portage/profile"
sudo mkdir -p "${PROFILE_DIR}"
sudo bash -c "echo sys-libs/glibc-2.10.1-r1 > ""${PROFILE_DIR}""/package.provided"
unset PROFILE_DIR

# Symlink for libstdc++.la issues. It appears that when packages get merged
# the .la files will be updated, and for libstdc++ it will use the wrong
# location. This works around that issue.
sudo ln -sf /usr/lib64/gcc \
  "${FLAGS_chroot}/usr/${CROSS_ARM_TARGET}/usr/lib/gcc"
sudo ln -sf /usr/lib64/gcc \
  "${FLAGS_chroot}/usr/${CROSS_X86_TARGET}/usr/lib/gcc"

# Setup make.conf and make.profile as symlinks to ones in revision control
sudo ln -sf "${CHROOT_CONFIG}/make.conf.${CROSS_ARM_TARGET}" \
  "${FLAGS_chroot}/usr/${CROSS_ARM_TARGET}/etc/make.conf"
sudo ln -sf "${CHROOT_OVERLAY}/profiles/default/linux/arm/10.0/chromeos/" \
  "${FLAGS_chroot}/usr/${CROSS_ARM_TARGET}/etc/make.profile"
sudo ln -sf "${CHROOT_CONFIG}/make.conf.${CROSS_X86_TARGET}" \
  "${FLAGS_chroot}/usr/${CROSS_X86_TARGET}/etc/make.conf"
sudo ln -sf "${CHROOT_OVERLAY}/profiles/default/linux/x86/10.0/chromeos/" \
  "${FLAGS_chroot}/usr/${CROSS_X86_TARGET}/etc/make.profile"

if [[ "$USER" = "chrome-bot" ]]; then
  # Copy ssh keys, so chroot'd chrome-bot can scp files from chrome-web.
  cp -r ~/.ssh "$FLAGS_chroot/home/$USER/"
fi

# Add file to indicate that it is a chroot
sudo touch "${FLAGS_chroot}/etc/debian_chroot"

# Unmount trunk
sudo umount "${FLAGS_chroot}/${CHROOT_TRUNK}"

# Clean up the chroot mounts
trap - EXIT
cleanup

if [[ "$FLAGS_chroot" = "$DEFAULT_CHROOT_DIR" ]]; then
  CHROOT_EXAMPLE_OPT=""
else
  CHROOT_EXAMPLE_OPT="--chroot=$FLAGS_chroot"
fi

echo "All set up.  To enter the chroot, run:"
echo "    $SCRIPTS_DIR/enter_chroot.sh $CHROOT_EXAMPLE_OPT"
echo ""
echo "CAUTION: Do *NOT* rm -rf the chroot directory; if there are stale bind"
echo "mounts you may end up deleting your source tree too.  To unmount and"
echo "delete the chroot cleanly, use:"
echo "    $0 --delete $CHROOT_EXAMPLE_OPT"

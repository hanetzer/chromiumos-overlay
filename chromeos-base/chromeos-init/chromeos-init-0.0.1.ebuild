# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit toolchain-funcs

DESCRIPTION="Upstart init scripts for Chromium OS"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE=""

DEPEND=""
RDEPEND="sys-apps/upstart"

src_unpack() {
	local platform="${CHROMEOS_ROOT}/src/platform"
	elog "Using platform: $platform"
	mkdir -p "${S}"
	cp -a "${platform}/init"/* "${S}" || die
}

src_install() {
	into /  # We want /sbin, not /usr/sbin, etc.

	# Install Upstart configuration files.
	dodir /etc/init
	install --owner=root --group=root --mode=0644 \
	  "${S}"/*.conf "${D}/etc/init/"

	# Install process killing util functions.
	dosbin "${S}/killers"
	# Install dbus daemon launcher to allow individual session instances
	dosbin "${S}/dbus-daemon-session"

	# Install startup/shutdown scripts.
	dosbin "${S}/chromeos_startup" "${S}/chromeos_shutdown"

	# Preseed /lib/chromiumos/devices which is by chromeos_startup to
	# populate /dev with enough devices to be able to do early init and
	# start the X server.
	# TODO: Evaluate devtmpfs when we start using kernel 2.6.32.
	DEVICES_DIR="/lib/chromiumos/devices"
	dodir "$DEVICES_DIR"
	dodir "${DEVICES_DIR}/dri"
	dodir "${DEVICES_DIR}/input"
	keepdir "${DEVICES_DIR}/pts"
	keepdir "${DEVICES_DIR}/shm"
	dosym /proc/self/fd "${DEVICES_DIR}/fd"
	dosym /proc/self/fd/0 "${DEVICES_DIR}/stdin"
	dosym /proc/self/fd/1 "${DEVICES_DIR}/stdout"
	dosym /proc/self/fd/2 "${DEVICES_DIR}/stderr"
	mknod --mode=0600 "${D}/${DEVICES_DIR}/initctl" p
	mknod --mode=0640 "${D}/${DEVICES_DIR}/mem"  c 1 1
	mknod --mode=0666 "${D}/${DEVICES_DIR}/null" c 1 3
	mknod --mode=0666 "${D}/${DEVICES_DIR}/zero" c 1 5
	mknod --mode=0666 "${D}/${DEVICES_DIR}/random" c 1 8
	mknod --mode=0666 "${D}/${DEVICES_DIR}/urandom" c 1 9
	mknod --mode=0660 "${D}/${DEVICES_DIR}/tty0" c 4 0
	mknod --mode=0660 "${D}/${DEVICES_DIR}/tty1" c 4 1
	mknod --mode=0660 "${D}/${DEVICES_DIR}/tty2" c 4 2
	mknod --mode=0666 "${D}/${DEVICES_DIR}/tty"  c 5 0
	mknod --mode=0660 "${D}/${DEVICES_DIR}/ttyMSM2" c 252 2
	mknod --mode=0600 "${D}/${DEVICES_DIR}/console" c 5 1
	mknod --mode=0666 "${D}/${DEVICES_DIR}/ptmx" c 5 2
	mknod --mode=0666 "${D}/${DEVICES_DIR}/loop0" b 7 0
	mknod --mode=0660 "${D}/${DEVICES_DIR}/sda"  b 8 0
	mknod --mode=0660 "${D}/${DEVICES_DIR}/sda1" b 8 1
	mknod --mode=0660 "${D}/${DEVICES_DIR}/sda2" b 8 2
	mknod --mode=0660 "${D}/${DEVICES_DIR}/sda3" b 8 3
	mknod --mode=0660 "${D}/${DEVICES_DIR}/sda4" b 8 4
	mknod --mode=0660 "${D}/${DEVICES_DIR}/sda5" b 8 5
	mknod --mode=0660 "${D}/${DEVICES_DIR}/sda6" b 8 6
	mknod --mode=0660 "${D}/${DEVICES_DIR}/sda7" b 8 7
	mknod --mode=0660 "${D}/${DEVICES_DIR}/sdb"  b 8 16
	mknod --mode=0660 "${D}/${DEVICES_DIR}/sdb1" b 8 17
	mknod --mode=0660 "${D}/${DEVICES_DIR}/sdb2" b 8 18
	mknod --mode=0660 "${D}/${DEVICES_DIR}/sdb3" b 8 19
	mknod --mode=0660 "${D}/${DEVICES_DIR}/sdb4" b 8 20
	mknod --mode=0660 "${D}/${DEVICES_DIR}/sdb5" b 8 21
	mknod --mode=0660 "${D}/${DEVICES_DIR}/sdb6" b 8 22
	mknod --mode=0660 "${D}/${DEVICES_DIR}/sdb7" b 8 23
	mknod --mode=0640 "${D}/${DEVICES_DIR}/input/mouse0" c 13 32
	mknod --mode=0640 "${D}/${DEVICES_DIR}/input/mice"   c 13 63
	mknod --mode=0640 "${D}/${DEVICES_DIR}/input/event0" c 13 64
	mknod --mode=0640 "${D}/${DEVICES_DIR}/input/event1" c 13 65
	mknod --mode=0640 "${D}/${DEVICES_DIR}/input/event2" c 13 66
	mknod --mode=0640 "${D}/${DEVICES_DIR}/input/event3" c 13 67
	mknod --mode=0640 "${D}/${DEVICES_DIR}/input/event4" c 13 68
	mknod --mode=0640 "${D}/${DEVICES_DIR}/input/event5" c 13 69
	mknod --mode=0640 "${D}/${DEVICES_DIR}/input/event6" c 13 70
	mknod --mode=0640 "${D}/${DEVICES_DIR}/input/event7" c 13 71
	mknod --mode=0640 "${D}/${DEVICES_DIR}/input/event8" c 13 72
	mknod --mode=0660 "${D}/${DEVICES_DIR}/fb0" c 29 0
	mknod --mode=0660 "${D}/${DEVICES_DIR}/mmcblk0" b 179 0
	mknod --mode=0660 "${D}/${DEVICES_DIR}/mmcblk0p1" b 179 1
	mknod --mode=0660 "${D}/${DEVICES_DIR}/mmcblk0p4" b 179 4
	mknod --mode=0660 "${D}/${DEVICES_DIR}/mmcblk1" b 179 16
	mknod --mode=0660 "${D}/${DEVICES_DIR}/mmcblk1p1" b 179 17
	mknod --mode=0660 "${D}/${DEVICES_DIR}/mmcblk1p4" b 179 20
	mknod --mode=0660 "${D}/${DEVICES_DIR}/dri/card0" c 226 0
	chown root.tty "${D}/${DEVICES_DIR}"/tty*
	chown root.kmem "${D}/${DEVICES_DIR}"/mem
	chown root.disk "${D}/${DEVICES_DIR}"/sda*
	chown root.video "${D}/${DEVICES_DIR}"/fb0
	chown root.video "${D}/${DEVICES_DIR}"/dri/card0
}

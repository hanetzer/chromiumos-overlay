# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="7e432462d2a35ffaf1493a1632f0375be4029480"
CROS_WORKON_TREE="9500272726ea7924a183489ae9ad9b0953b7ad12"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_INCREMENTAL_BUILD=1
PLATFORM_SUBDIR="container_utils"

inherit cros-workon platform udev user

DESCRIPTION="Helper utilities for generic containers"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="+device_jail"

RDEPEND="
	chromeos-base/libbrillo
	device_jail? (
		virtual/udev
		sys-fs/fuse
	)
"
DEPEND="${RDEPEND}"

pkg_setup() {
	if use device_jail; then
		enewuser "devicejail"
		enewgroup "devicejail"
	fi
	cros-workon_pkg_setup
}

src_install() {
	cd "${OUT}"
	dobin mount_extension_image

	if use device_jail; then
		dobin device_jail_fs

		fowners devicejail:devicejail /usr/bin/device_jail_fs

		into /usr/local
		dobin device_jail_utility

		cd "${S}"
		insinto /etc/init
		doins device-jail.conf

		udev_dorules udev/*.rules
	fi
}

pkg_preinst() {
	enewuser "user-containers"
	enewgroup "user-containers"
}

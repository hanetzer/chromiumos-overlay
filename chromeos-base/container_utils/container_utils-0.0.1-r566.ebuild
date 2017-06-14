# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="e7a393066b49aa0bc37977712ecf5f5e8b5cbd2c"
CROS_WORKON_TREE="99af2ab86fc5cd69b3cbd42bc8b175587211736a"
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
IUSE="device_jail"

RDEPEND="
	chromeos-base/libbrillo
	device_jail? (
		virtual/udev
		sys-fs/fuse
	)
"
DEPEND="
	${RDEPEND}
	chromeos-base/session_manager-client
	chromeos-base/system_api
"

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

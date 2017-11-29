# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="32fe60d364dfeba63e6ce81f3223a27f4e0b6a82"
CROS_WORKON_TREE="f47d5dd96c8d396e7c450d5e8973acd8cc16c102"
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
IUSE=""

RDEPEND="
	chromeos-base/libbrillo
	virtual/udev
	sys-fs/fuse
"
DEPEND="
	${RDEPEND}
	chromeos-base/imageloader-client
	chromeos-base/session_manager-client
	chromeos-base/system_api
"

pkg_setup() {
	enewuser "devicejail"
	enewgroup "devicejail"
	cros-workon_pkg_setup
}

src_install() {
	cd "${OUT}"
	dobin mount_extension_image
	dobin device_jail_fs

	fowners devicejail:devicejail /usr/bin/device_jail_fs

	into /usr/local
	dobin device_jail_utility

	cd "${S}"
	insinto /etc/init
	doins device-jail.conf

	udev_dorules udev/*.rules
}

pkg_preinst() {
	enewuser "user-containers"
	enewgroup "user-containers"
}

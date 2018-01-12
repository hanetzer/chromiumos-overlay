# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="ec57d5c9a8f33f1fc1a015ae7e55792aa7410315"
CROS_WORKON_TREE="2d1192a7ecb4e2d2361ffc49910c7e49b8b72097"
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

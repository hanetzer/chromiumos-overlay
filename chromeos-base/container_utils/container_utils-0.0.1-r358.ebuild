# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="f89306fc25651b2f7bfbcb56e9ff8be7e03b5165"
CROS_WORKON_TREE="8131f9212c01327c42b2b21680912811917323a0"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
PLATFORM_SUBDIR="container_utils"

inherit cros-workon platform udev user

DESCRIPTION="Helper utilities for generic containers"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
	chromeos-base/libbrillo
	chromeos-base/libcontainer
	virtual/udev
	sys-fs/fuse
"
DEPEND="${RDEPEND}"

pkg_setup() {
	enewuser "devicejail"
	enewgroup "devicejail"
	cros-workon_pkg_setup
}

src_install() {
	cd "${OUT}"
	dobin run_oci
	dobin device_jail_fs

	fowners devicejail:devicejail /usr/bin/device_jail_fs

	into /usr/local
	dobin device_jail_utility

	cd "${S}"
	insinto /etc/init
	doins device-jail.conf

	udev_dorules udev/*.rules
}

platform_pkg_test() {
	local tests=(
		container_config_parser_unittest
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		# platform_test takes care of setting up your test environment
		platform_test "run" "${OUT}/${test_bin}"
	done
}

pkg_preinst() {
	enewuser "user-containers"
	enewgroup "user-containers"
}

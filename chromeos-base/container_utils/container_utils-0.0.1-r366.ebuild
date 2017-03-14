# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="74ea0af8082273780e3dd445eb76965fb2337522"
CROS_WORKON_TREE="57499e53b790d5f5d2047cb04a459f17d3bf9774"
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

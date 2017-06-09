# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="cd01872c8126e350c94f13bfed896f49b075e573"
CROS_WORKON_TREE="8008ab808a0795be02d306a454c33c2e01b3007c"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="midis"

inherit cros-workon platform user

DESCRIPTION="MIDI Server for Chromium OS"
HOMEPAGE=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

src_install() {
	dobin "${OUT}"/midis

	insinto /etc/init
	doins init/*.conf

	# Install headers
	insinto /usr/include/midis/
	doins -r messages.h
}

pkg_preinst() {
	enewuser midis
	enewgroup midis
}

platform_pkg_test() {
	local unit_tests=(
		"client_test"
		"client_tracker_test"
		"device_test"
		"device_tracker_test"
		"udev_handler_test"
	)

	local test
	for test in "${unit_tests[@]}"; do
		platform_test "run" "${OUT}"/${test}
	done
}

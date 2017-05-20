# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="8389ccd71e65f6130819f778166182c67cf3eca7"
CROS_WORKON_TREE="233aa6c97ad0c0cc11d3033e8d87cff7d97d5e03"
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

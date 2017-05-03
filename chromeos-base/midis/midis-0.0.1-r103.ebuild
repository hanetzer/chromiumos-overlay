# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="011533f1caad1a00234970d920c5f3996ff5f5d0"
CROS_WORKON_TREE="44602e14257c7a6c29536fdf9cf4288ed3e0e958"
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
}

pkg_preinst() {
	enewuser midis
	enewgroup midis
}

platform_pkg_test() {
	local unit_tests=(
		"device_test"
		"device_tracker_test"
		"udev_handler_test"
	)

	local test
	for test in "${unit_tests[@]}"; do
		platform_test "run" "${OUT}"/${test}
	done
}

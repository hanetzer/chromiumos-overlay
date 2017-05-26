# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="a11c9ce740418c694cd866666dba07b2981ee046"
CROS_WORKON_TREE="a3b5bd30ae22cef8d8f7c2d819dfd6edca18270b"
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

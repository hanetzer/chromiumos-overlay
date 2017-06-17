# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="91f6440261bb2bb7ed7037fb9f6e956bf5db91e9"
CROS_WORKON_TREE="62dad8a2f8cb941cc94a04d8f6fa713bf918f37e"
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
	local tests=(
		"midis_testrunner"
	)

	local test
	for test in "${tests[@]}"; do
		platform_test "run" "${OUT}"/${test}
	done
}

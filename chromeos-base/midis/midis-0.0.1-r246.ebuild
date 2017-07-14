# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="2c31d5d9edcbdf3434a41b776e29128b1570aab0"
CROS_WORKON_TREE="b69866b593d1df12ceae45e2410ad4d07b7a51b7"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="midis"

inherit cros-workon platform user multilib

DESCRIPTION="MIDI Server for Chromium OS"
HOMEPAGE=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

src_install() {
	dobin "${OUT}"/midis

	insinto /etc/init
	doins init/*.conf

	# Install libraries
	./platform2_preinstall.sh "${OUT}"
	dolib.a "${OUT}"/libmidis.a
	insinto "/usr/$(get_libdir)/pkgconfig"
	doins "${OUT}"/obj/midis/libmidis.pc

	# Install headers
	insinto /usr/include/midis/
	doins -r messages.h
	doins libmidis/clientlib.h
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

# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="0ea2b837ac96c64b0d326d877483d75f9493b1a6"
CROS_WORKON_TREE="f6b55dc3c68efaf7965ecfc0185aa2a37765b907"
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
	doins libmidis/clientlib.h

	# Install midis DBUS configuration file
	insinto /etc/dbus-1/system.d
	doins dbus_permissions/org.chromium.Midis.conf
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

# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="f7f8a8d19e0607c0fc920346c8c39dee1ccad35f"
CROS_WORKON_TREE="eda4aaae595a2f83d1e085e33a93cfc3b3df62b5"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}/platform2"

PLATFORM_SUBDIR="buffet"

inherit cros-workon libchrome platform

DESCRIPTION="Local and cloud communication services for Chromium OS"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD-Google"
SLOT=0
KEYWORDS="*"

RDEPEND="
	chromeos-base/libchromeos
	!<chromeos-base/platform2-0.0.10
"

DEPEND="
	${RDEPEND}
	test? ( dev-cpp/gmock )
	dev-cpp/gtest
"

src_install() {
	insinto "/usr/$(get_libdir)/pkgconfig"
	local v
	for v in "${LIBCHROME_VERS[@]}"; do
		./libbuffet/preinstall.sh "${OUT}" "${v}"
		dolib.so "${OUT}/lib/libbuffet-${v}.so"
		doins "${OUT}/lib/libbuffet-${v}.pc"
	done

	# Install header files from libbuffet
	insinto /usr/include/libbuffet
	doins libbuffet/*.h

	dobin "${OUT}"/buffet
	dobin "${OUT}"/buffet_client

	# DBus configuration.
	insinto /etc/dbus-1/system.d
	doins etc/dbus-1/org.chromium.Buffet.conf

	# Base GCD command and state definitions.
	insinto /etc/buffet
	doins etc/buffet/*

	# Upstart script.
	insinto /etc/init
	doins etc/init/buffet.conf
}

platform_pkg_test() {
	local tests=(
		buffet_testrunner
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}

# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="ae03e7a47dc58dede79886819f5cd3f72cd08fb9"
CROS_WORKON_TREE="48bc9a82699e4b676e020817a24e908f759d6b10"
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
	dobin "${OUT}"/buffet
	dobin "${OUT}"/buffet_client

	# DBus configuration.
	insinto /etc/dbus-1/system.d
	doins etc/dbus-1/org.chromium.Buffet.conf

	# Base GCD command definitions.
	insinto /etc/buffet
	doins etc/buffet/gcd.json

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

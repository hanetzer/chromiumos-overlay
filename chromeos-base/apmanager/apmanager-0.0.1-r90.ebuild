# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="ff4dbaa0443578ec8df194f8d7d2f9cd316c7a04"
CROS_WORKON_TREE="1572cac7e20555c43db804589be05c638d0caa4a"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}/platform2"

PLATFORM_SUBDIR="apmanager"

inherit cros-workon platform user

DESCRIPTION="Access Point Manager for Chromium OS"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT=0
IUSE="test"
KEYWORDS="*"

RDEPEND="
	chromeos-base/libchromeos
"

DEPEND="
	${RDEPEND}
	test? (
		dev-cpp/gmock
		dev-cpp/gtest
	)
"

src_install() {
	dobin "${OUT}"/apmanagerd

	# DBus configuration.
	insinto /etc/dbus-1/system.d
	doins dbus_permissions/org.chromium.apmanager.conf
}

pkg_preinst() {
	# Create user and group for apmanager.
	enewuser "apmanager"
	enewgroup "apmanager"
}

platform_pkg_test() {
	local tests=(
		apmanager_testrunner
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}

# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="22351537a6caa0ce2696e308902e017ced1d235d"
CROS_WORKON_TREE="c8c6b70c8c4860601095372e7f05ffb34e88996e"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="peerd"

inherit cros-workon platform user

DESCRIPTION="Local peer discovery services for Chromium OS"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD-Google"
SLOT=0
KEYWORDS="*"

RDEPEND="
	chromeos-base/libchromeos
	net-dns/avahi-daemon
"

DEPEND="
	${RDEPEND}
	test? ( dev-cpp/gmock )
	dev-cpp/gtest
"

pkg_preinst() {
	# Create user and group for peerd.
	enewuser "peerd"
	enewgroup "peerd"
}

src_install() {
	dobin "${OUT}/peerd"
	# Install init scripts.
	insinto /etc/init
	doins init/peerd.conf
	# Install DBus configuration files.
	insinto /etc/dbus-1/system.d
	doins dbus/org.chromium.peerd.conf
}

platform_pkg_test() {
	local tests=(
		peerd_testrunner
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}

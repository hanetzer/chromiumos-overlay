# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="1e7c026bf6fef556364fd94e7be8efafc998cbbc"
CROS_WORKON_TREE="6521441452a62c471b124396c4deb7a22b5d4622"
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

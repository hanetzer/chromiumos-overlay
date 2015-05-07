# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="a53573ae32ca50c9df56d96e42564962ba0a5fdc"
CROS_WORKON_TREE="1c1dddef178677f5a25da1deb26610278193ef13"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="privetd"

inherit cros-workon platform user

DESCRIPTION="Privet protocol handler for Chrome OS Core"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD-Google"
SLOT=0
KEYWORDS="*"

COMMON_DEPEND="
	chromeos-base/libchromeos
	chromeos-base/webserver
"

RDEPEND="
	${COMMON_DEPEND}
	chromeos-base/apmanager
	chromeos-base/peerd
"

DEPEND="
	${COMMON_DEPEND}
	test? (
		dev-cpp/gmock
		dev-cpp/gtest
	)
"

pkg_preinst() {
	# Create user and group for privetd.
	enewuser "privetd"
	enewgroup "privetd"
	# Additional groups to put privetd into.
	enewgroup "apmanager"
	enewgroup "buffet"
	enewgroup "peerd"
}

src_install() {
	dobin "${OUT}/privetd"
	# Install init scripts.
	insinto /etc/init
	doins init/privetd.conf
	# Install DBus configuration files.
	insinto /etc/dbus-1/system.d
	doins dbus_bindings/org.chromium.privetd.conf
}

platform_pkg_test() {
	local tests=(
		privetd_testrunner
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}

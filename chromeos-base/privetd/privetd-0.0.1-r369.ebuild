# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="0f83caa0c9f8b79e7fd77df65d52df3b4ba2cbf6"
CROS_WORKON_TREE="7ad3149dbf6d11ccc94c208343559a0db38d3dd0"
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
	chromeos-base/libchrome_crypto
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

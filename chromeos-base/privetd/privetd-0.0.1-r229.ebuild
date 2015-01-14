# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="77d2f50e072fe57b235a7e3c0a7390a62e7246f1"
CROS_WORKON_TREE="060e706f19177ee25bf1d7f58fb6b8bdb54c1eb4"
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
	chromeos-base/libwebserv
"

RDEPEND="
	${COMMON_DEPEND}
	chromeos-base/apmanager
	chromeos-base/peerd
	net-firewall/iptables
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

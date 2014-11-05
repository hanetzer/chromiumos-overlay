# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="170c986b1e1f987f6bf42076a1553c8660c77458"
CROS_WORKON_TREE="3f5c032bf9c2fc5174142bd2fc9cb37fdfbec4a7"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}/platform2"

PLATFORM_SUBDIR="privetd"

inherit cros-workon platform

DESCRIPTION="Privet protocol handler for Chrome OS Core"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD-Google"
SLOT=0
KEYWORDS="*"

COMMON_DEPEND="
	chromeos-base/libchromeos
	chromeos-base/libwebserv
"

RDEPEND="
	${COMMON_DEPEND}
	chromeos-base/peerd
"

DEPEND="
	${COMMON_DEPEND}
	test? (
		dev-cpp/gmock
		dev-cpp/gtest
	)
"

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

# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="1ca78ecc9ba0b7145c9b9723b27b38bb9bb14787"
CROS_WORKON_TREE="a475b90c5dec2a30221be596f598e2e8d0ba2fdc"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="goldfishd"

inherit cros-workon platform

DESCRIPTION="Android Emulator Daemon for Chromium OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/goldfishd/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

DEPEND="
	chromeos-base/libbrillo
	"

RDEPEND="
	chromeos-base/autotest-client
	${DEPEND}
	"

src_install() {
	dobin "${OUT}"/goldfishd

	insinto /etc/init
	doins init/*.conf
}

platform_pkg_test() {
	platform_test "run" "${OUT}/goldfishd_test_runner"
}

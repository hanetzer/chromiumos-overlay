# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="9837f2f051a0e8f431e470f35934d024ff4f6c0f"
CROS_WORKON_TREE="02c1709bcd694749ea3da37b7bcb99e6d8bbc687"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="brdebug"
PLATFORM_NATIVE_TEST="yes"

inherit cros-workon platform

DESCRIPTION="Manage device properties for Brillo debug link."
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="test"

RDEPEND="
	chromeos-base/libchromeos
	chromeos-base/peerd
"

DEPEND="
	${RDEPEND}
	test? ( dev-cpp/gtest )
"

src_install() {
	dobin "${OUT}"/brdebugd
}

platform_pkg_test() {
	platform_test "run" "${OUT}/brdebug_unittest"
}

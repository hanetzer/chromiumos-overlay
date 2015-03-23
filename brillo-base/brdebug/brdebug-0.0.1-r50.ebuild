# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="7e92095afeee425c52791b22d9b4c1fb286b6e7c"
CROS_WORKON_TREE="fc3bf54d19a5067e3e8648e80237a9baa617e902"
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

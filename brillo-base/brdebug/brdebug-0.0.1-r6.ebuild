# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="37bc6f992e888879a82d8c4b6be7a5b6e7f583b2"
CROS_WORKON_TREE="8aca26f2088d6dc836ec594586fc349840b8e33e"
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

RDEPEND=""
DEPEND="${RDEPEND}
	test? ( dev-cpp/gtest )"

src_install() {
	dosbin "${OUT}"/brdebugd
}

platform_pkg_test() {
	platform_test "run" "${OUT}/brdebug_unittest"
}

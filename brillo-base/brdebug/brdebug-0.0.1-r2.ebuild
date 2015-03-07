# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="f8f672defe5eea88eec9b7becc7b012a0a868a72"
CROS_WORKON_TREE="305abf804a30dff7a31ad1d9564fe35b20a68d68"
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

# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="5e978a78b864431bb8348f5cfcb1ea1b1b65ad79"
CROS_WORKON_TREE="89f37c811b5dea606ff8b09a7b1d821efd87a77a"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"

PLATFORM_SUBDIR="chromeos-config"

inherit cros-workon platform

DESCRIPTION="Chrome OS configuration tools"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT=0
KEYWORDS="*"
IUSE="cros_host"

RDEPEND="
	chromeos-base/libbrillo
	sys-apps/dtc
"

DEPEND="
	${RDEPEND}
"

src_install() {
	dolib.so "${OUT}/lib/libcros_config.so"

	"${S}"/platform2_preinstall.sh "${PV}" "/usr/include/chromeos" "${OUT}"
	insinto "/usr/$(get_libdir)/pkgconfig"
	doins "${OUT}"/libcros_config.pc

	dobin "${OUT}"/cros_config
	use cros_host && dobin "${OUT}"/cros_config_host
}

platform_pkg_test() {
	local tests=(
		cros_config_unittest
		cros_config_main_unittest
	)

	use cros_host && tests+=( cros_config_host_main_unittest )

	local test_bin

	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done

	./run_tests.sh || die "cros_config unit tests have errors"
}

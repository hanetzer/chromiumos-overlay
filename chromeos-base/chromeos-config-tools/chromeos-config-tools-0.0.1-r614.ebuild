# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="b0417392e5b26b4039e61cadc8e7e82befa86812"
CROS_WORKON_TREE="b0d9dbc151f056146afc983f4c9bd9fc667e4702"
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

	./test-readme.sh || die "README.md has errors"

	local pytest
	for pytest in *test.py; do
		einfo "Running tests in ${pytest}"
		"./${pytest}" || die "Tests failed at ${pytest}"
	done
}

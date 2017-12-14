# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="cdb39943acc98f91a7c0619b16a105916efc8ea6"
CROS_WORKON_TREE="7afe36e4f5386785cc027ba206801caf48c8b73e"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"

PLATFORM_SUBDIR="chromeos-config"

inherit cros-workon platform

DESCRIPTION="Chrome OS configuration tools"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/chromeos-config"

LICENSE="BSD-Google"
SLOT=0
KEYWORDS="*"
IUSE="json"

RDEPEND="
	chromeos-base/libbrillo
	sys-apps/dtc
"

DEPEND="${RDEPEND}"

src_install() {
	dolib.so "${OUT}/lib/libcros_config.so"

	"${S}"/platform2_preinstall.sh "${PV}" "/usr/include/chromeos" "${OUT}"
	insinto "/usr/$(get_libdir)/pkgconfig"
	doins "${OUT}"/libcros_config.pc

	dobin "${OUT}"/cros_config
}

platform_pkg_test() {
	# Run this here since we may not run cros_config_main_unittest.
	./chromeos-config-test-setup.sh
	local tests=(
		fake_cros_config_unittest
	)

	# TODO(sjg#chromium.org): Get JSON tests to pass. They currently die
	# with a segfault.
	if ! use json; then
		tests+=(
			cros_config_unittest
			cros_config_main_unittest
		)
	fi

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}

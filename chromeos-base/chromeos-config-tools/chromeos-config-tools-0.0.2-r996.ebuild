# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="5dbceea5e91932e855404807d551d73894580735"
CROS_WORKON_TREE=("0295472676671915bab943e84d561ed834ea7622" "ae2f23bcd21f39ab4fd644e5188ec0d173c4ef47")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_SUBTREE="common-mk chromeos-config"

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

	insinto "/usr/include/chromeos/chromeos-config/libcros_config"
	doins "${S}"/libcros_config/*.h

	"${S}"/platform2_preinstall.sh "${PV}" "/usr/include/chromeos" "${OUT}"
	insinto "/usr/$(get_libdir)/pkgconfig"
	doins "${OUT}"/libcros_config.pc

	insinto "/usr/include/cros_config"
	doins "libcros_config/cros_config_interface.h"
	doins "libcros_config/cros_config.h"
	doins "libcros_config/fake_cros_config.h"

	dobin "${OUT}"/cros_config
}

platform_pkg_test() {
	# Run this here since we may not run cros_config_main_unittest.
	./chromeos-config-test-setup.sh
	local tests=(
		fake_cros_config_unittest
		cros_config_unittest
		cros_config_main_unittest
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}

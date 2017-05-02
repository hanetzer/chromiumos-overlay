# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="3249fe596fc4935b376258217ca65c8cafafc811"
CROS_WORKON_TREE="fe9f31a931d79297ca86d994e1c9406fee22f561"
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
IUSE=""

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
}

platform_pkg_test() {
	local tests=(
		cros_config_unittest
		cros_config_main_unittest
	)

	local test_bin

	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}

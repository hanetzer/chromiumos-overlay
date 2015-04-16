# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="d9038e8775d9c3f2590ddd08716125d29e7e46ec"
CROS_WORKON_TREE="3967bd3838344efd4dbd9467f11f7f69ab475d0f"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="libprotobinder"

inherit cros-workon platform udev

DESCRIPTION="Library to provide Binder IPC."
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="test"

RDEPEND="
	!brillo-base/libbrillobinder
	chromeos-base/libchromeos
"

DEPEND="${RDEPEND}
	test? ( dev-cpp/gmock )
	dev-cpp/gtest
"

src_install() {
	./preinstall.sh "${OUT}"
	insinto /usr/$(get_libdir)/pkgconfig
	doins "${OUT}"/*.pc

	# Add lib
	dolib.so "${OUT}/lib/libprotobinder.so"

	# Adding headers
	insinto /usr/include/protobinder
	doins *.h

	# Adding udev rules
	udev_dorules udev/*.rules

	# Adding proto files
	insinto /usr/share/proto
	doins idl/*.proto
}

platform_pkg_test() {
	local tests=( libprotobinder_test )

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}

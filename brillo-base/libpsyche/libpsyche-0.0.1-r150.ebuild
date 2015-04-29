# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="d03f2662c11263e457bafd1aa4844134d3685007"
CROS_WORKON_TREE="ac7da817b77984626203db11c0e901fbbadcfa2a"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="psyche"
PLATFORM_GYP_FILE="libpsyche.gyp"

inherit cros-workon platform

DESCRIPTION="Client library for service registration and lookup"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="test"

RDEPEND="
	brillo-base/libprotobinder
	dev-libs/protobuf
"
DEPEND="${RDEPEND}
	test? ( dev-cpp/gtest )"

# Daemons that use libpsyche need psyched to be running, but we can't use
# RDEPEND since it'll cause a circular dependency. See
# http://devmanual.gentoo.org/general-concepts/dependencies/.
PDEPEND="brillo-base/psyche"

src_install() {
	./preinstall.sh "${OUT}"
	insinto /usr/$(get_libdir)/pkgconfig
	doins "${OUT}"/*.pc

	dolib.so "${OUT}"/lib/libpsyche.so

	insinto /usr/include/psyche
	doins lib/psyche/*.h
}

platform_pkg_test() {
	local tests=(
		libpsyche_test
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test run "${OUT}/${test_bin}"
	done
}

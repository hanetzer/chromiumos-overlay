# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="b1e4f85016d4e580db10f6bdacb27e95900d41b2"
CROS_WORKON_TREE="da8b0673f77a85b8d48905c191222f2d5df9fb80"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="soma"

inherit cros-workon platform

DESCRIPTION="Service bundle config processor service for Brillo."
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="test"

RDEPEND="brillo-base/libprotobinder"
DEPEND="${RDEPEND}
	dev-cpp/gtest"

src_install() {
	dosbin "${OUT}"/somad
	dobin "${OUT}"/soma_client

	# Adding libsoma and headers.
	./preinstall.sh "${OUT}"
	insinto /usr/$(get_libdir)/pkgconfig
	doins "${OUT}"/*.pc

	dolib.so "${OUT}"/lib/libsoma.so

	insinto /usr/include/"${PN}"
	doins libsoma/*.h

	# Adding init scripts.
	insinto /etc/init
	doins init/*.conf

	# Adding proto files.
	insinto /usr/share/proto
	doins idl/*.proto
}

platform_pkg_test() {
	local tests=( somad_test )

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}

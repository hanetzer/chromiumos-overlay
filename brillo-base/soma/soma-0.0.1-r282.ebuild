# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="a53573ae32ca50c9df56d96e42564962ba0a5fdc"
CROS_WORKON_TREE="1c1dddef178677f5a25da1deb26610278193ef13"
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

RDEPEND="
	brillo-base/libprotobinder
	brillo-base/libpsyche
"
DEPEND="${RDEPEND}
	dev-cpp/gtest"

src_install() {
	dosbin "${OUT}"/somad

	# Adding libsoma and headers.
	./preinstall.sh "${OUT}" || die
	insinto /usr/$(get_libdir)/pkgconfig
	doins "${OUT}"/*.pc

	dolib.so "${OUT}"/lib/libsoma.so

	insinto /usr/include/"${PN}"
	doins lib/soma/*.h

	# Adding init scripts.
	insinto /etc/init
	doins init/*.conf

	# Adding proto files.
	insinto /usr/share/proto
	doins idl/*.proto

	# Adding directory for container specs.
	dodir /etc/container_specs
}

platform_pkg_test() {
	local tests=( somad_test libsoma_test )

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}

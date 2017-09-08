# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="9b8c71f9b476ec8ccf979dae55e7015fe8d6b307"
CROS_WORKON_TREE="e3094b87b873d96e45e2186066233276ca5777cc"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}/platform2"

PLATFORM_SUBDIR="hammerd"

inherit cros-workon platform user

DESCRIPTION="A daemon to update EC firmware of hammer, the base of the detachable."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/hammerd/"

LICENSE="BSD-Google"
SLOT=0
KEYWORDS="*"

DEPEND="
	chromeos-base/libbrillo
	chromeos-base/vboot_reference
	dev-libs/openssl
	sys-apps/flashmap
	virtual/libusb:1
"
RDEPEND="${DEPEND}"

pkg_preinst() {
	# Create user and group for hammerd
	enewuser "hammerd"
	enewgroup "hammerd"
}

src_install() {
	dobin "${OUT}/hammerd"

	# Install upstart config.
	insinto /etc/init
	doins init/*.conf

	# Install exposed API.
	dolib.so "${OUT}"/lib/libhammerd-api.so
	insinto /usr/include/hammerd/
	doins hammerd_api.h
}

platform_pkg_test() {
	platform_test "run" "${OUT}/unittest_runner"
}

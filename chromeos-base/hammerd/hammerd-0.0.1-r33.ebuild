# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="98e29a3dbd0eca277490a184016838821d99f112"
CROS_WORKON_TREE="cfcd4e18ab476780ac9fbdb139d8928baf0725fd"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}/platform2"

PLATFORM_SUBDIR="hammerd"

inherit cros-workon platform udev user

DESCRIPTION="A daemon to update EC firmware of hammer, the base of the detachable."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/hammerd/"

LICENSE="BSD-Google"
SLOT=0
KEYWORDS="*"

DEPEND="
	chromeos-base/libbrillo
	chromeos-base/vboot_reference
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
	udev_dorules 99-hammerd.rules
}

platform_pkg_test() {
	platform_test "run" "${OUT}/unittest_runner"
}

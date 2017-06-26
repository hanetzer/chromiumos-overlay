# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="d991372a8fe523042c477d017652e17623f2c038"
CROS_WORKON_TREE="730532f799afaf6b1343c8daa8341d95e33b7b7c"
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

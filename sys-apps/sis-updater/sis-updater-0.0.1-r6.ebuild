# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="793f51c53f7e0c6ff1662c0efcff0bfe1f61e0cd"
CROS_WORKON_TREE="ecfbf9636634ca6efab431a930c0d308f84f089c"
CROS_WORKON_PROJECT="chromiumos/third_party/sis-updater"

inherit cros-workon libchrome udev user

DESCRIPTION="A tool to update SiS firmware on Mimo from Chromium OS."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/third_party/sis-updater"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

DEPEND="chromeos-base/libbrillo"

RDEPEND="${DEPEND}"

src_configure() {
	cros-workon_src_configure
}

src_install() {
	dosbin sis-updater
	udev_dorules conf/99-sis-usb.rules
}

pkg_preinst() {
	enewuser cfm-firmware-updaters
	enewgroup cfm-firmware-updaters
}

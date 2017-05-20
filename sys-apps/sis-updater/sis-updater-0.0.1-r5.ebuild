# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="3cd8fe58f994440d2e5e6238e45611b9f2dc709c"
CROS_WORKON_TREE="789ab4068573126bf53935d5e40ce73965b05fdd"
CROS_WORKON_PROJECT="chromiumos/third_party/sis-updater"

inherit cros-workon udev user

DESCRIPTION="A tool to update SiS firmware on Mimo from Chromium OS."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/third_party/sis-updater"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="${DEPEND}"

src_install() {
	dosbin sis-updater
	udev_dorules conf/99-sis-usb.rules
}

pkg_preinst() {
	enewuser cfm-firmware-updaters
	enewgroup cfm-firmware-updaters
}

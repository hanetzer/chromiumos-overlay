# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="600840897bd02d32ceaa44c208aad71284d92c2d"
CROS_WORKON_TREE="d72781321f50352a6b3ebb03a11192fb5c2a4ae9"
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
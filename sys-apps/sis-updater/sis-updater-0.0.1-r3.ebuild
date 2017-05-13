# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="f8cdd7917157bb744fcc4d79e7e56e5ae94c2b09"
CROS_WORKON_TREE="d15cfaed8901399b9bfdf8b423e4bfa4b1334482"
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

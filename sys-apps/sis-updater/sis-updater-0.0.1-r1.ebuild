# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="49c8a661237ee1201eed9a51625b227dee4dd4c5"
CROS_WORKON_TREE="4b825dc642cb6eb9a060e54bf8d69288fbee4904"
CROS_WORKON_PROJECT="chromiumos/third_party/sis-updater"

inherit cros-workon udev

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

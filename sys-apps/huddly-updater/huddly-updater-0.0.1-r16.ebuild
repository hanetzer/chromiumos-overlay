# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="e80dd18c56ba7f15dcb19f07c518c68ce20229b7"
CROS_WORKON_TREE="480b27ec9f7ff94bc29214bfe4da1eea639f854b"
CROS_WORKON_PROJECT="chromiumos/third_party/huddly-updater"

inherit cros-workon libchrome udev user

DESCRIPTION="A utility to update Huddly camera firmware"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/third_party/huddly-updater"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

DEPEND="
	chromeos-base/libbrillo
	virtual/libusb:1
	virtual/libudev:0="

RDEPEND="${DEPEND}
	app-arch/unzip"

src_install() {
	dosbin huddly-updater
	udev_dorules conf/99-huddly.rules
}

pkg_preinst() {
	enewuser cfm-firmware-updaters
	enewgroup cfm-firmware-updaters
}

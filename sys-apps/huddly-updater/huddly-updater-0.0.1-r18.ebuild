# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="91b6c184792dc32583f6b56d3bc45731733119d6"
CROS_WORKON_TREE="1a8c1f83cd5417d6016e39cc9dfed121c0f18fca"
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

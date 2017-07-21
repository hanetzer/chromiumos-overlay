# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="695d5523ccc905971316f8120ed8adfcecf2337d"
CROS_WORKON_TREE="018b451215b6420e6250aa1a8d0f196a4fe4a96e"
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

src_configure() {
	cros-workon_src_configure
}

src_install() {
	dosbin huddly-updater
	udev_dorules conf/99-huddly.rules
}

pkg_preinst() {
	enewuser cfm-firmware-updaters
	enewgroup cfm-firmware-updaters
}

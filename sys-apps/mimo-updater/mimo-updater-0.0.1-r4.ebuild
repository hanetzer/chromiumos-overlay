# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="ca4b9d39936daa0e31a7d842b4a4c666cdf053ce"
CROS_WORKON_TREE="efde71510e6074eea138e8031108b0848b61d22a"
CROS_WORKON_PROJECT="chromiumos/third_party/mimo-updater"

inherit cros-workon udev

DESCRIPTION="A tool to interact with a Mimo device from Chromium OS."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/third_party/mimo-updater"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

DEPEND="
	virtual/libusb:1
	virtual/libudev:0="

RDEPEND="${DEPEND}"

src_install() {
	dosbin mimo-updater
	udev_dorules conf/90-displaylink-usb.rules
}

pkg_preinst() {
	enewuser cfm-firmware-updaters
	enewgroup cfm-firmware-updaters
}

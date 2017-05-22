# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="991ac72229fe57667d134b884abeb01a4fe0237e"
CROS_WORKON_TREE="9171fa76a3f6163628784207e8602e6d7f7aeabe"
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

# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# Trimmed down version of libiio with just the local backend libiio library.

EAPI=5

inherit cmake-utils

DESCRIPTION="Library for interfacing with IIO devices"
HOMEPAGE="https://github.com/analogdevicesinc/libiio"
SRC_URI="https://github.com/analogdevicesinc/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"
IUSE=""

src_configure() {
	# All backends are disabled except the local one.
	# Network backend requires avahi
	# USB backend requires usb. When used INSTALL_UDEV_RULE option may be set.
	mycmakeargs=(
		-DWITH_IIOD=OFF
		-DWITH_NETWORK_BACKEND=OFF
		-DWITH_SERIAL_BACKEND=OFF
		-DWITH_USB_BACKEND=OFF
		-DWITH_TESTS=OFF
		-DPYTHON_BINDINGS=OFF
	)
	cmake-utils_src_configure
}

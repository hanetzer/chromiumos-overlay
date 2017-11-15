# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU Gener Public License v2

EAPI=5

inherit cmake-utils

DESCRIPTION="a userland driver for IPP-over-USB class USB devices."
HOMEPAGE="https://github.com/tillkamppeter/ippusbxd"
SRC_URI="https://github.com/tillkamppeter/ippusbxd/${P}.tar.gz"

KEYWORDS="*"
LICENSE="Apache-2.0"
SLOT="0"
IUSE="usb zeroconf"

DEPEND="
	usb? ( virtual/libusb )
	zeroconf? ( >=net-dns/avahi-0.6.32 )
"

S="${WORKDIR}/${P}/src"

src_install() {
	dobin "${BUILD_DIR}/ippusbxd"
}

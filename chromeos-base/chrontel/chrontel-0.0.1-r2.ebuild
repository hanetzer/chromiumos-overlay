# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="e4e01a5f2a7039f3b0a40b7c5c81d1eadc2cb042"
inherit cros-workon

DESCRIPTION="Chrontel CH7036 User Space Driver"
HOMEPAGE="http://www.chrontel.com"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE=""

CROS_WORKON_LOCALNAME="../third_party/chrontel"

RDEPEND="x11-libs/libXrandr
	x11-libs/libX11"

DEPEND="${RDEPEND}"

src_compile() {
	tc-export CC PKG_CONFIG
	emake || die "end compile failed."
}

src_install() {
	dobin ch7036_monitor
	dobin ch7036_debug

	dodir /lib/firmware/chrontel
	insinto /lib/firmware/chrontel
	doins fw7036.bin

	insinto /etc/init
	doins chrontel.conf
}

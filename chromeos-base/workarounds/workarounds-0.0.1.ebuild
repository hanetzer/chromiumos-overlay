# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

DESCRIPTION="Chrome OS workarounds utilities."
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
KEYWORDS="x86 arm"
SLOT="0"
IUSE=""

src_unpack() {
	local workarounds="${CHROMEOS_ROOT}/src/platform/workarounds"
	elog "Using workarounds sources: $workarounds"
	cp -ar "${workarounds}" "${S}" || die
}

src_install() {
        dobin "${S}/mkcrosusb"
        dosym /usr/bin/mkcrosusb /usr/bin/channel_change
}

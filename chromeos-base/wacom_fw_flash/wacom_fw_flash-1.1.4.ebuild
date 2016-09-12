# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

inherit toolchain-funcs

DESCRIPTION="Wacom EMR flash for Firmware Update"
GIT_SHA1="205bd9ff0b263bb6f60f6ac1b2f0195aba70ac3b"
HOMEPAGE="https://github.com/flying-elephant/wacom_source/"
MY_P="wacom_source-${GIT_SHA1}"
SRC_URI="https://github.com/flying-elephant/wacom_source/archive/${GIT_SHA1}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${MY_P}/wacom_flash"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

src_configure() {
	tc-export CC
}

src_install() {
	cd "${S}"
	dosbin wacom_flash
}

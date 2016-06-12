# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

inherit toolchain-funcs

DESCRIPTION="Wacom EMR flash for Firmware Update"
GIT_SHA1="b46cbbe60ffa43c2be771ec4c6b6ffe69c3ed6d9"
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

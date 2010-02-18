# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit toolchain-funcs

DESCRIPTION="Audio configuration files."
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}"

ASOUNDCONF="${S}/${PN}/etc/asound.conf"

src_unpack() {
	local platform="${CHROMEOS_ROOT}/src/platform"
	elog "Using platform: $platform"
	mkdir -p $(dirname "${ASOUNDCONF}")
	cp -a "${platform}/audioconfig/asound.conf" "${ASOUNDCONF}" || die
	chmod 0644 "${ASOUNDRC}"
}

src_install() {
	dodir "/etc"
	cp -a "${ASOUNDCONF}" "${D}/etc/"
}

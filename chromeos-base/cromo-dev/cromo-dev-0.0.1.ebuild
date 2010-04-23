# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

DESCRIPTION="Chromium OS modem manager dev files"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"

DEPEND=""
RDEPEND=""

src_unpack() {
	local platform="${CHROMEOS_ROOT}/src/platform"
	elog "Using platform: $platform"
	mkdir -p "${S}/cromo"
	cp -a "${platform}/cromo" "${S}" || die
}

src_install() {
	(cd cromo && emake DESTDIR=${D} "install-headers")
}

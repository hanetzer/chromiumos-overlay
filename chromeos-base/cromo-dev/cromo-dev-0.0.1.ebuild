# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

DESCRIPTION="Chromium OS modem manager dev files"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"

DEPEND="dev-libs/dbus-c++"
RDEPEND=""

src_unpack() {
	local platform="${CHROMEOS_ROOT}/src/platform"
	cp -a "${platform}/cromo" "${S}" || die "Failed to unpack sources"
}

src_compile() {
	elog "No compile"
}

src_install() {
	emake DESTDIR=${D} "install-headers"
}

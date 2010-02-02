# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit toolchain-funcs

DESCRIPTION="Chrome OS assets (images, sounds, etc)"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

src_unpack() {
	local assets="${CHROMEOS_ROOT}/src/platform/assets"
	elog "Using assets dir: $assets"
	mkdir -p "${S}"
	cp -a "${assets}"/* "${S}" || die
}

src_install() {
	local dest="${D}/usr/share/chromeos-assets"
	mkdir -p --mode=0755 "${dest}/images"
	cp "${S}"/images/* "${dest}/images"
	chmod 0744 "${dest}"/images/*

	# TODO: chromeos cursors
}

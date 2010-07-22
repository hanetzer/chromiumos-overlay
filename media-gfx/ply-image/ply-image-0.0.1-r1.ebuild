# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="215d2daccc531e4391e486f4de51ed9200f752ca"
inherit toolchain-funcs cros-workon

DESCRIPTION="Utility that dumps a png image to the frame buffer."
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE=""

DEPEND="media-libs/libpng"
RDEPEND="${DEPEND}"

src_compile() {
	if tc-is-cross-compiler ; then
		tc-getCC
	fi
	emake || die "emake failed"
}

src_install() {
	mkdir -p "${D}/usr/bin"
	cp "${S}/src/ply-image" "${D}/usr/bin"
}

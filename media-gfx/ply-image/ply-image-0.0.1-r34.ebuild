# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="0d5d6243f1974cd3eb09d5637c42ffde184933ab"
CROS_WORKON_TREE="84c72f95bcdf7a60ba9199b28ff3a612d7d6ff1d"
CROS_WORKON_PROJECT="chromiumos/third_party/ply-image"

inherit toolchain-funcs cros-workon

DESCRIPTION="Utility that dumps a png image to the frame buffer."
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE=""

DEPEND="media-libs/libpng
	x11-libs/libdrm"
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

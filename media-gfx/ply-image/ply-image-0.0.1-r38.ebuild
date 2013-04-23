# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="ce88f9230b2f1f1634a608da72086304f3afe423"
CROS_WORKON_TREE="61eecf51abab2de5d3efaf02a4e9d4d53dc77dc3"
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

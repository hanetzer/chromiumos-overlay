# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="03cdddd3e6603b1b2b834ee8ecbe428684ed4d93"
CROS_WORKON_TREE="e0a7d5c55cfc0162192fae6a80ce200a19b71eb3"
CROS_WORKON_PROJECT="chromiumos/third_party/ply-image"
CROS_WORKON_OUTOFTREE_BUILD="1"

inherit toolchain-funcs cros-workon

DESCRIPTION="Utility that dumps a png image to the frame buffer"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="media-libs/libpng
	x11-libs/libdrm"
RDEPEND="${DEPEND}"

src_configure() {
	cros-workon_src_configure
	tc-export CC
	export OUT=$(cros-workon_get_build_dir)
	export SRC=${S}
	mkdir -p "${OUT}"
}

src_install() {
	dobin "${OUT}"/ply-image
}

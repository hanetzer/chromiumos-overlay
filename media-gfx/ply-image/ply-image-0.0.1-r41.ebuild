# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="69b538525e1676dbdb57fbfaba31f58b19863572"
CROS_WORKON_TREE="5d4d98e8247f19c0802584b53630cdd19d4f701c"
CROS_WORKON_PROJECT="chromiumos/third_party/ply-image"
CROS_WORKON_OUTOFTREE_BUILD="1"

inherit toolchain-funcs cros-workon

DESCRIPTION="Utility that dumps a png image to the frame buffer"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"
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

# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT=f5b1284e877189ae39f5be47c7b55b4002d9f6a6
CROS_WORKON_TREE="16df0c37406aa9d921697f8bae26fb6cc9cbb260"
CROS_WORKON_PROJECT="chromiumos/third_party/khronos"

inherit toolchain-funcs cros-workon

DESCRIPTION="OpenGL|ES mock library"
HOMEPAGE="http://www.khronos.org/opengles/2_X/"
SRC_URI=""

LICENSE="SGI-B-2.0"
SLOT="0"
KEYWORDS="arm x86"
IUSE=""

RDEPEND="x11-libs/libX11
	x11-drivers/opengles-headers"
DEPEND="${RDEPEND}"

CROS_WORKON_LOCALNAME="khronos"

src_compile() {
	tc-export AR CC CXX LD NM RANLIB
	scons || die
}

src_install() {
	dolib libEGL.so libGLESv2.so
}

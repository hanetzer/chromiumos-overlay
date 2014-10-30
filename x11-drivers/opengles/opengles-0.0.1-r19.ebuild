# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="507ea5cf5ea4c77624d954f11ee9bb0a32005353"
CROS_WORKON_TREE="b10f36c8b83879543140bd02a0b0dac870bebd6c"
CROS_WORKON_PROJECT="chromiumos/third_party/khronos"

inherit scons-utils toolchain-funcs cros-workon

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
	escons
}

src_install() {
	dolib libEGL.so libGLESv2.so
}

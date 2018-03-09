# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="f427d0ac31d1878a6e2c9209f63a8f560983b6bf"
CROS_WORKON_TREE="25c2d35c1546ce9edc46d9622c9cf327be7922be"
CROS_WORKON_PROJECT="chromiumos/third_party/khronos"
CROS_WORKON_LOCALNAME="khronos"

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

src_compile() {
	tc-export AR CC CXX LD NM RANLIB
	escons
}

src_install() {
	dolib libEGL.so libGLESv2.so
}

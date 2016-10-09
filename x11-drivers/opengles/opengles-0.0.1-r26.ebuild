# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="669e6d72d5e559f30c854e5b4e990d3ccfd98bcf"
CROS_WORKON_TREE="f976d830543c38506c95bae3252730965422541e"
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

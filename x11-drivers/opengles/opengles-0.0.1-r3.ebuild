# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="bc3c1486800a25189f9ca4f7420de9bd10b1ea34"

inherit toolchain-funcs cros-workon

DESCRIPTION="OpenGL|ES mock library."
HOMEPAGE="http://www.khronos.org/opengles/2_X/"
SRC_URI=""
LICENSE="SGI-B-2.0"
SLOT="0"
KEYWORDS="x86 arm"
IUSE=""

RDEPEND="x11-libs/libX11
	x11-drivers/opengles-headers"
DEPEND="${RDEPEND}"

CROS_WORKON_PROJECT="khronos"
CROS_WORKON_LOCALNAME="khronos"

src_compile() {
	if tc-is-cross-compiler ; then
		tc-getCC
		tc-getCXX
		tc-getAR
		tc-getRANLIB
		tc-getLD
		tc-getNM
		export PKG_CONFIG_PATH="${ROOT}/usr/lib/pkgconfig/"
		export CCFLAGS="$CFLAGS"
	fi

	scons || die "compile failed"
}

src_install() {
	# libraries
	dolib "${S}/libEGL.so"
	dolib "${S}/libGLESv2.so"
}

# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit toolchain-funcs

DESCRIPTION="OpenGL|ES mock library."
HOMEPAGE="http://www.khronos.org/opengles/2_X/"
SRC_URI=""
LICENSE="SGI-B-2.0"
SLOT="0"
KEYWORDS="x86 arm"
IUSE=""

RDEPEND="x11-libs/libX11"
DEPEND="${RDEPEND}"

src_unpack() {
	local khronos="${CHROMEOS_ROOT}/src/third_party/khronos/files"
	elog "Using khronos dir: $khronos"
	mkdir -p "${S}/khronos"

	cp -a "${khronos}"/* "${S}/khronos" || die
}

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

	pushd "khronos"
	scons || die "compile failed"
	popd
}

src_install() {
	# headers
	insinto /usr/include/EGL
	doins "${S}/khronos/include/EGL/egl.h"
	doins "${S}/khronos/include/EGL/eglplatform.h"
	doins "${S}/khronos/include/EGL/eglext.h"
	insinto /usr/include/KHR
	doins "${S}/khronos/include/KHR/khrplatform.h"
	insinto /usr/include/GLES2
	doins "${S}/khronos/include/GLES2/gl2.h"
	doins "${S}/khronos/include/GLES2/gl2ext.h"
	doins "${S}/khronos/include/GLES2/gl2platform.h"

	# libraries
	dolib "${S}/khronos/libEGL.so"
	dolib "${S}/khronos/libGLESv2.so"
}

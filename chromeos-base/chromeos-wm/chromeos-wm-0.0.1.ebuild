# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit toolchain-funcs

DESCRIPTION="Chrome OS window manager."
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE="opengles"

RDEPEND="dev-cpp/gflags
	dev-cpp/glog
	dev-libs/libpcre
	dev-libs/protobuf
	media-libs/libpng
	x11-libs/cairo
	x11-libs/libxcb
	x11-libs/libX11
	x11-libs/libXdamage
	x11-libs/libXext
	!opengles? ( virtual/opengl )
	opengles? ( x11-drivers/opengles )"
DEPEND="chromeos-base/libchrome
	dev-libs/vectormath
	${RDEPEND}"

src_unpack() {
	local platform="${CHROMEOS_ROOT}/src/platform/"
	elog "Using platform dir: $platform"
	mkdir -p "${S}/window_manager"

	cp -a "${platform}"/window_manager/* "${S}/window_manager" || die
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

	local backend
	if use opengles ; then
		backend=OPENGLES
	else
		backend=OPENGL
	fi

	# TODO: breakpad should have its own ebuild and we should add to
	# hard-target-depends. Perhaps the same for src/third_party/chrome
	# and src/common
	pushd "window_manager"
	scons BACKEND="$backend" wm screenshot || die "window_manager compile failed"
	popd
}

src_test() {
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

	pushd "window_manager"
	scons tests || die "failed to build tests"
	popd

	if ! use x86 ; then
		echo Skipping tests on non-x86 platform...
	else
		LIB_PATH="${SYSROOT}/usr/lib:${SYSROOT}/lib"
		LIBC_PATH="${SYSROOT}/usr/lib/gcc/${CHOST}/"$(gcc-fullversion)
		X11_PATH="${SYSROOT}/usr/lib/opengl/xorg-x11/lib"
		pushd "window_manager"
		for test in ./*_test; do
			LD_LIBRARY_PATH="$LIB_PATH:$LIBC_PATH:$X11_PATH" \
			    "${SYSROOT}/lib/ld-linux.so.2" \
			    "$test" ${GTEST_ARGS} || die "$test failed"
		done
		popd
	fi
}

src_install() {
	mkdir -p "${D}/usr/bin"
	cp "${S}/window_manager/wm" "${D}/usr/bin/chromeos-wm"
	cp "${S}/window_manager/screenshot" "${D}/usr/bin/screenshot"
}

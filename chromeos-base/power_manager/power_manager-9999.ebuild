# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit toolchain-funcs

DESCRIPTION="Power Manager for Chromium OS"
HOMEPAGE="http://src.chromium.org"
LICENSE="BSD"
SLOT="0"
IUSE="test"
KEYWORDS="amd64 x86 arm"

RDEPEND="x11-libs/libX11
         x11-libs/libXext"

DEPEND="${RDEPEND}
        x11-proto/xextproto
        test? ( dev-cpp/gtest )"

src_unpack() {
	local platform="${CHROMEOS_ROOT}/src/platform/"
	elog "Using platform: $platform"
	mkdir -p "${S}/power_manager"
	cp -a "${platform}"/power_manager/* "${S}/power_manager" || die
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

	# TODO(davidjames): parallel builds
	pushd power_manager
	scons || die "power_manager compile failed."
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

	# Build tests
	pushd power_manager
	scons xidle_unittest || die "xidle_unittest compile failed."
	popd

	# Run tests if we're on x86
	if ! use x86 ; then
		echo Skipping tests on non-x86 platform...
	else
		LIBC_PATH="${SYSROOT}/usr/lib/gcc/${CHOST}/"$(gcc-fullversion)
		LD_LIBRARY_PATH="${SYSROOT}/usr/lib:${SYSROOT}/lib:$LIBC_PATH" \
		    "${SYSROOT}/lib/ld-linux.so.2" \
		    "${S}/power_manager/xidle_unittest" \
		    ${GTEST_ARGS} || die "unit tests failed"
	fi
}

src_install() {
	mkdir -p "${D}/usr/bin"
	cp "${S}/power_manager/xidle-example" "${D}/usr/bin"
}

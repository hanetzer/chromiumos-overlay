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

RDEPEND="chromeos-base/libcros
         dev-cpp/gflags
         dev-cpp/glog
         x11-base/xorg-server
         x11-libs/gtk+
         x11-libs/libX11
         x11-libs/libXext"

DEPEND="${RDEPEND}
        chromeos-base/libchrome
        test? ( dev-cpp/gmock )
        test? ( dev-cpp/gtest )
        test? ( x11-libs/libXtst )
        x11-proto/xextproto"

src_unpack() {
	local platform="${CHROMEOS_ROOT}/src/platform/"
	elog "Using platform: $platform"
	mkdir -p "${S}/power_manager"
	cp -a "${platform}"/power_manager/* "${S}/power_manager" || die
	mkdir -p "${S}/cros"
	cp -a "${platform}"/cros/* "${S}/cros" || die
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
	scons tests || die "tests compile failed."
	popd

	# Run tests if we're on x86
	if ! use x86 ; then
		echo Skipping tests on non-x86 platform...
	else
		export DISPLAY=:1 
		trap 'kill %1 && wait' exit
		"${SYSROOT}/usr/bin/Xvfb" ${DISPLAY} 2>/dev/null &
		sleep 2
		"${S}/power_manager/xidle_unittest" \
		    ${GTEST_ARGS} || die "xidle_unittest failed"
		kill %1 && wait
		trap - exit
		"${S}/power_manager/idle_dimmer_unittest" \
		    ${GTEST_ARGS} || die "idle_dimmer_unittest failed"
		"${S}/power_manager/plug_dimmer_unittest" \
		    ${GTEST_ARGS} || die "plug_dimmer_unittest failed"
	fi
}

src_install() {
	exeinto "/usr/bin"
	doexe "${S}/power_manager/backlight-tool"
	doexe "${S}/power_manager/powerd"
	doexe "${S}/power_manager/xidle-example"
}

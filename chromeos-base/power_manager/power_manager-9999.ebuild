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
	chromeos-base/metrics
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
	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG

	# TODO(davidjames): parallel builds
	pushd power_manager
	scons || die "power_manager compile failed."
	popd
}

src_test() {
	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG

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
		for ut in powerd xidle; do
			"${S}/power_manager/${ut}_unittest" \
				${GTEST_ARGS} || die "${ut}_unittest failed"
		done
		kill %1 && wait
		trap - exit
		for ut in idle_dimmer plug_dimmer; do
			"${S}/power_manager/${ut}_unittest" \
				${GTEST_ARGS} || die "${ut}_unittest failed"
		done
	fi
}

src_install() {
	dobin "${S}/power_manager/backlight-tool"
	dobin "${S}/power_manager/powerd"
	dobin "${S}/power_manager/powerd_lock_screen"
	dobin "${S}/power_manager/powerd_suspend"
	dobin "${S}/power_manager/send_metrics_on_resume"
	dobin "${S}/power_manager/xidle-example"
	insinto "/usr/share/power_manager"
	for item in ${S}/power_manager/config/*; do
		doins ${item}
	done
}

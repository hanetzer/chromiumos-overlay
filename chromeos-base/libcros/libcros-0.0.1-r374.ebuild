# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="8374a59e176764560c20149de53497580c6adbac"
CROS_WORKON_PROJECT="chromiumos/platform/cros"
CROS_WORKON_LOCALNAME="cros"

inherit toolchain-funcs cros-debug cros-workon scons-utils

DESCRIPTION="Bridge library for Chromium OS"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="install_tests cmt"

RDEPEND="chromeos-base/flimflam
	dev-libs/dbus-glib
	dev-libs/glib
	dev-libs/libpcre
	sys-apps/dbus
	cmt? ( x11-apps/xinput )"

DEPEND="${RDEPEND}
	chromeos-base/chromeos-assets
	chromeos-base/libchrome:0[cros-debug=]
	chromeos-base/libchromeos
	chromeos-base/system_api
	chromeos-base/update_engine
	dev-cpp/gtest"

src_compile() {
	tc-export AR CC CXX LD NM RANLIB PKG_CONFIG
	cros-debug-add-NDEBUG

	# Sanity check for load.cc. Detect missing INIT_FUNC() calls.
	python "${FILESDIR}"/check_load_cc.py < load.cc || \
		die "INIT_FUNC(s) are missing from load.cc."

	export CCFLAGS="$CFLAGS"
	escons -f SConstruct.chromiumos
	# Add -fPIC when building libcrosapi.a so that it works on ARM
	export CCFLAGS="$CCFLAGS -fPIC"
	escons -f SConstruct.chromiumos crosapi
	if use install_tests; then
		escons -f SConstruct.chromiumos test
	fi
}

src_install() {
	dolib.a libcrosapi.a

	insinto /usr/include/cros
	doins *.h

	exeinto /opt/google/chrome/chromeos
	doexe libcros.so
	use install_tests && doexe monitor_sms
}

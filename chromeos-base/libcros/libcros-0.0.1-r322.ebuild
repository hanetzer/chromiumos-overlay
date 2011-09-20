# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="8945a71eed22ac8872ab5e3fef6a77085d5ef196"
CROS_WORKON_PROJECT="chromiumos/platform/cros"

inherit flag-o-matic toolchain-funcs cros-debug cros-workon

DESCRIPTION="Bridge library for Chromium OS"
HOMEPAGE="http://www.chromium.org/"
IUSE="install_tests cmt"
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"

RDEPEND="chromeos-base/flimflam
	dev-libs/dbus-glib
	dev-libs/glib
	dev-libs/libpcre
	sys-apps/dbus
	cmt? ( x11-apps/xinput )"

DEPEND="${RDEPEND}
	chromeos-base/chromeos-assets
	chromeos-base/libchrome
	chromeos-base/libchromeos
	chromeos-base/system_api
	chromeos-base/update_engine
	dev-cpp/gtest"

CROS_WORKON_LOCALNAME=$(basename ${CROS_WORKON_PROJECT})

src_compile() {
	cros-debug-add-NDEBUG
	if tc-is-cross-compiler ; then
		tc-getCC
		tc-getCXX
		tc-getAR
		tc-getRANLIB
		tc-getLD
		tc-getNM
		tc-getPROG PKG_CONFIG pkg-config
		export PKG_CONFIG_PATH="${ROOT}/usr/lib/pkgconfig/"
		export CCFLAGS="$CFLAGS"
	fi

	# Sanity check for load.cc. Detect missing INIT_FUNC() calls.
	python "${FILESDIR}"/check_load_cc.py < load.cc || \
		die "INIT_FUNC(s) are missing from load.cc."

	scons -f SConstruct.chromiumos || die "cros compile failed."
	# Add -fPIC when building libcrosapi.a so that it works on ARM
	export CCFLAGS="$CCFLAGS -fPIC"
	scons -f SConstruct.chromiumos crosapi || die "crosapi compile failed."
	if use install_tests; then
		scons -f SConstruct.chromiumos test || \
			die "cros tests compile failed."
	fi
}

src_test() {
	if tc-is-cross-compiler ; then
		tc-getCC
		tc-getCXX
		tc-getAR
		tc-getRANLIB
		tc-getLD
		tc-getNM
		tc-getPROG PKG_CONFIG pkg-config
		export PKG_CONFIG_PATH="${ROOT}/usr/lib/pkgconfig/"
		export CCFLAGS="$CFLAGS"
	fi

	scons -f SConstruct.chromiumos unittest || die
	./libcros_unittests || die
}

src_install() {
	dolib.a "${S}/libcrosapi.a"

	insinto /usr/include/cros
	doins *.h

	insinto /opt/google/chrome/chromeos
	insopts -m0755
	doins "${S}/libcros.so"
	if use install_tests; then
		doins "${S}/cryptohome_drive"
		doins "${S}/monitor_mount"
		doins "${S}/monitor_network"
		doins "${S}/monitor_power"
		doins "${S}/monitor_sms"
		doins "${S}/monitor_update_engine"
	fi

	insinto /opt/google/touchpad
	doins "${FILESDIR}"/tpcontrol_synclient
	doins "${FILESDIR}"/tpcontrol
	doins "${FILESDIR}"/tpcontrol_xinput

	insinto /etc/dbus-1/system.d
	doins "${S}/LibCrosService.conf"

	insinto /usr/share/dbus-1/services
	doins "${S}/org.chromium.LibCrosService"
}

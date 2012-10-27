# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="87a4ae88915e3dc22dbb1327002e1daf769ef23e"
CROS_WORKON_TREE="e7293bd800fb001e08ecc32403b191da985de64a"

EAPI=2
CROS_WORKON_PROJECT="chromiumos/platform/shill"

inherit cros-debug cros-workon toolchain-funcs multilib

DESCRIPTION="Shill Connection Manager for Chromium OS"
HOMEPAGE="http://src.chromium.org"
LICENSE="BSD"
SLOT="0"
IUSE="test"
KEYWORDS="amd64 arm x86"

RDEPEND="chromeos-base/bootstat
	chromeos-base/chromeos-minijail
	!<chromeos-base/flimflam-0.0.1-r527
	chromeos-base/libchrome:125070[cros-debug=]
	chromeos-base/libchromeos
	chromeos-base/metrics
	>=chromeos-base/mobile-providers-0.0.1-r12
	chromeos-base/vpn-manager
	dev-libs/dbus-c++
	>=dev-libs/glib-2.30
	dev-libs/nss
	net-dialup/ppp
	net-dns/c-ares"

DEPEND="${RDEPEND}
	chromeos-base/system_api
	chromeos-base/wimax_manager
	test? ( dev-cpp/gmock )
	test? ( dev-cpp/gtest )
	virtual/modemmanager"

make_flags() {
	echo LIBDIR="/usr/$(get_libdir)"
}

src_compile() {
	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG
	cros-debug-add-NDEBUG

	emake $(make_flags) shill shims || die "shill compile failed."
}

src_test() {
	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG
	cros-debug-add-NDEBUG

	# Build tests
	emake $(make_flags) shill_unittest || die "tests compile failed."

	# Run tests if we're on x86
	if ! use x86 && ! use amd64 ; then
		echo Skipping tests on non-x86/amd64 platform...
	else
		for ut in shill ; do
			"${S}/${ut}_unittest" \
				${GTEST_ARGS} || die "${ut}_unittest failed"
		done
	fi
}

src_install() {
	dobin bin/ff_debug || die
	dobin bin/mm_debug || die
	dobin bin/set_apn || die
	dobin bin/set_arpgw || die
	dobin bin/wpa_debug || die
	dobin shill || die
	local shims_dir="/usr/$(get_libdir)/shill/shims"
	exeinto "${shims_dir}"
	doexe build/shims/nss-get-cert || die
	doexe build/shims/openvpn-script || die
	doexe build/shims/set-apn-helper || die
	doexe build/shims/shill-pppd-plugin.so || die
	insinto "${shims_dir}"
	doins build/shims/wpa_supplicant.conf || die
	insinto /etc
	doins shims/nsswitch.conf || die
	# Install introspection XML
	insinto /usr/share/dbus-1/interfaces
	doins dbus_bindings/org.chromium.flimflam.*.xml
}

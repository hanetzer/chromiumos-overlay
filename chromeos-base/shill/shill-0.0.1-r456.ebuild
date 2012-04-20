# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="b27beee2e85a1ad3d68a1218c8c4fef4214626e8"
CROS_WORKON_TREE="90a5f34b4c8589a2d4137d3a5b262eedd0b24e66"

EAPI=2
CROS_WORKON_PROJECT="chromiumos/platform/shill"

inherit cros-debug cros-workon toolchain-funcs multilib

DESCRIPTION="Shill Connection Manager for Chromium OS"
HOMEPAGE="http://src.chromium.org"
LICENSE="BSD"
SLOT="0"
IUSE="test"
KEYWORDS="amd64 arm x86"

RDEPEND="chromeos-base/libchrome:125070[cros-debug=]
	chromeos-base/libchromeos
	chromeos-base/metrics
	>=chromeos-base/mobile-providers-0.0.1-r12
	chromeos-base/vpn-manager
	dev-libs/dbus-c++
	>=dev-libs/glib-2.30
	net-dns/c-ares"

DEPEND="${RDEPEND}
	chromeos-base/system_api
	test? ( dev-cpp/gmock )
	test? ( dev-cpp/gtest )
	virtual/modemmanager"

make_flags() {
	echo LIBDIR="/usr/$(get_libdir)"
}

src_compile() {
	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG
	cros-debug-add-NDEBUG

	emake $(make_flags) shill || die "shill compile failed."
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
	dobin "shill" || die
	# Install upstart config file
	insinto /etc/init
	doins shill.conf || die
	# Install introspection XML
	insinto /usr/share/dbus-1/interfaces
	doins dbus_bindings/org.chromium.flimflam.*.xml
}

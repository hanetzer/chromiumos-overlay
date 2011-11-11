# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="7ec7131cbc4e192ea044cf761317e71699f7c190"
CROS_WORKON_PROJECT="chromiumos/platform/shill"

inherit cros-debug cros-workon toolchain-funcs

DESCRIPTION="Shill Connection Manager for Chromium OS"
HOMEPAGE="http://src.chromium.org"
LICENSE="BSD"
SLOT="0"
IUSE="test"
KEYWORDS="amd64 arm x86"

RDEPEND="chromeos-base/libchrome
	chromeos-base/libchromeos
	>=chromeos-base/mobile-providers-0.0.1-r12
	dev-libs/dbus-c++
	>=dev-libs/glib-2.30
	net-dns/c-ares"

DEPEND="${RDEPEND}
	chromeos-base/system_api
	test? ( dev-cpp/gmock )
	test? ( dev-cpp/gtest )
	net-misc/modemmanager"

src_compile() {
	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG
	cros-debug-add-NDEBUG

	emake shill || die "shill compile failed."
}

src_test() {
	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG
	cros-debug-add-NDEBUG

	# Build tests
	emake shill_unittest || die "tests compile failed."

	# Run tests if we're on x86
	if ! use x86 ; then
		echo Skipping tests on non-x86 platform...
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
}

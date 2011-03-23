# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="78431af05a5cec8febfb5276ed9b690317f5b2c2"

inherit cros-debug cros-workon toolchain-funcs

DESCRIPTION="VPN tools"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="x86 arm"
IUSE=""

RDEPEND="chromeos-base/libchrome
	 chromeos-base/libchromeos
	 dev-cpp/gflags
	 net-misc/strongswan[cisco,nat-transport]"
DEPEND="${RDEPEND}
	 dev-cpp/gtest"

src_compile() {
	tc-export CXX PKG_CONFIG
	cros-debug-add-NDEBUG
	emake || die "vpn-manager compile failed."
}

src_test() {
	tc-export CXX PKG_CONFIG
	cros-debug-add-NDEBUG
	emake tests || die "could not build tests"
	if ! use x86; then
	        echo Skipping unit tests on non-x86 platform
	else
	        for test in ./*_test; do
		        "${test}" ${GTEST_ARGS} || die "${test} failed"
		done
	fi
}

src_install() {
	into /usr || die
	dosbin "l2tpipsec_vpn" || die
	exeinto /usr/libexec/l2tpipsec_vpn || die
	doexe "bin/pluto_updown" || die
}

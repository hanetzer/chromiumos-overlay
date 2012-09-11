# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="bcfc17cf4f4ad7f90b365abada1e3991bfe02a5a"
CROS_WORKON_TREE="482758b2628f6cce1913020b920b5ca0bd88c7fc"

EAPI=2
CROS_WORKON_PROJECT="chromiumos/platform/vpn-manager"

inherit cros-debug cros-workon toolchain-funcs multilib

DESCRIPTION="VPN tools"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

LIBCHROME_VERS="125070"

RDEPEND="chromeos-base/libchrome:${LIBCHROME_VERS}[cros-debug=]
	 chromeos-base/libchromeos
	 dev-cpp/gflags
	 dev-libs/openssl
	 net-dialup/xl2tpd
	 net-misc/strongswan[cisco,nat-transport]"
DEPEND="${RDEPEND}
	 dev-cpp/gtest"

make_flags() {
	echo LIBDIR="/usr/$(get_libdir)" BASE_VER=${LIBCHROME_VERS}
}

src_compile() {
	tc-export CXX PKG_CONFIG
	cros-debug-add-NDEBUG
	emake $(make_flags) || die "vpn-manager compile failed."
}

src_test() {
	tc-export CXX PKG_CONFIG
	cros-debug-add-NDEBUG
	emake $(make_flags) tests || die "could not build tests"
	if ! use x86 && ! use amd64 ; then
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

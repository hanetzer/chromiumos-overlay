# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="a44e2fe928a0b7ad1e06745a4f3794deea95c063"
CROS_WORKON_TREE="df2d70780b233c9158737654c5b0892a92fd0082"
CROS_WORKON_PROJECT="chromiumos/platform/vpn-manager"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-debug cros-workon multilib

DESCRIPTION="VPN tools"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="-asan -clang platform2"
REQUIRED_USE="asan? ( clang )"

LIBCHROME_VERS="180609"

RDEPEND="chromeos-base/libchrome:${LIBCHROME_VERS}[cros-debug=]
	 chromeos-base/libchromeos
	 chromeos-base/platform2
	 dev-cpp/gflags
	 dev-libs/openssl
	 net-dialup/xl2tpd
	 net-misc/strongswan"
DEPEND="${RDEPEND}
	 dev-cpp/gtest"

src_prepare() {
	use platform2 && return 0
	cros-workon_src_prepare
}

src_configure() {
	use platform2 && return 0
	clang-setup-env
	cros-workon_src_configure
	export LIBDIR="/usr/$(get_libdir)"
}

src_compile() {
	use platform2 && return 0
	cros-workon_src_compile
}

src_test() {
	use platform2 && return 0

	if ! use x86 && ! use amd64 ; then
		echo Skipping unit tests on non-x86 platform
	else
		cros-workon_src_test
	fi
}

src_install() {
	use platform2 && return 0

	cros-workon_src_install
	insinto /usr/include/chromeos/vpn-manager
	doins service_error.h
	dosbin "${OUT}"/l2tpipsec_vpn
	exeinto /usr/libexec/l2tpipsec_vpn
	doexe "bin/pluto_updown"
}

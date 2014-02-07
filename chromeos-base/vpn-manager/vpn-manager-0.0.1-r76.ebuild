# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="17f76e03fb8b082c1fe071408be593f0195896b5"
CROS_WORKON_TREE="5f719d616a735ac4e8a1d28b6565ca5d49f12c17"
CROS_WORKON_PROJECT="chromiumos/platform/vpn-manager"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-debug cros-workon multilib

DESCRIPTION="VPN tools"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="-asan -clang platform2"
REQUIRED_USE="asan? ( clang )"

LIBCHROME_VERS="180609"

RDEPEND="chromeos-base/libchrome:${LIBCHROME_VERS}[cros-debug=]
	 chromeos-base/platform2
	 dev-cpp/gflags
	 dev-libs/openssl
	 net-dialup/xl2tpd
	 net-misc/strongswan"
DEPEND="${RDEPEND}
	 dev-cpp/gtest"

RDEPEND="!platform2? ( ${RDEPEND} )"
DEPEND="!platform2? ( ${DEPEND} )"

src_prepare() {
	if use platform2; then
		printf '\n\n\n'
		ewarn "This package doesn't install anything with USE=platform2."
		ewarn "You want to use the new chromeos-base/platform2 package."
		printf '\n\n\n'
		return 0
	fi
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

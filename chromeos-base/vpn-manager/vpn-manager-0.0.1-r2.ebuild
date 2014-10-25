# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="849c5eb5ed084377f5a590e34ae44761d940d704"
CROS_WORKON_TREE="f9bbd60c925e654941967ce8d705540f49867bb9"
CROS_WORKON_INCREMENTAL_BUILD="1"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_DESTDIR="${S}/platform2"

PLATFORM_SUBDIR="vpn-manager"

inherit cros-workon platform

DESCRIPTION="L2TP/IPsec VPN manager for Chromium OS"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD-Google"
SLOT="0"
IUSE="test"
KEYWORDS="*"

RDEPEND="
	chromeos-base/libchromeos
	!<chromeos-base/platform2-0.0.14
	net-dialup/ppp
	net-dialup/xl2tpd
	net-misc/strongswan
"

DEPEND="${RDEPEND}
	test? ( dev-cpp/gmock )
	dev-cpp/gtest"

src_install() {
	insinto /usr/include/chromeos/vpn-manager
	doins service_error.h
	dosbin "${OUT}"/l2tpipsec_vpn
	exeinto /usr/libexec/l2tpipsec_vpn
	doexe bin/pluto_updown
}

platform_pkg_test() {
	platform_test "run" "${OUT}"/daemon_test
	platform_test "run" "${OUT}"/ipsec_manager_test
	platform_test "run" "${OUT}"/l2tp_manager_test
	platform_test "run" "${OUT}"/service_manager_test
}

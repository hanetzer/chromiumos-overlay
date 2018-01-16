# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="c34e2c0bcf6ccba0944a9f354a83301a7040f1d3"
CROS_WORKON_TREE="db21009f57fd505d198a14f710b2183ca899194f"
CROS_WORKON_INCREMENTAL_BUILD="1"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="vpn-manager"

inherit cros-workon platform

DESCRIPTION="L2TP/IPsec VPN manager for Chromium OS"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
	chromeos-base/libbrillo
	net-dialup/ppp
	net-dialup/xl2tpd
	net-vpn/strongswan
"

DEPEND="${RDEPEND}"

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

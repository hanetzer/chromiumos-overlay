# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="2f0ee1db4579dbe27ff96e3b1565cfec7126488a"
CROS_WORKON_TREE="5a6badf66b0219330e63c88d8b3e2d33ed21e8e6"
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

# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="aa5d96ccaefe4d7ab567a6ee0a20789f6318476b"
CROS_WORKON_TREE="2f3a186fc9e428e5d19b28ed9b262f8839bc23c9"
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
	net-misc/strongswan
"

DEPEND="${RDEPEND}
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

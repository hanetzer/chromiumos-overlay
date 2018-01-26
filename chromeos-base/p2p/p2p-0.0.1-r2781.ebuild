# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="4f5cf601fb4bb58dc4c2b10ab87e02213a456a7b"
CROS_WORKON_TREE="7176a4b07a8349f928cd8d3c57a7aa634b086278"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_USE_VCSID=1
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="p2p"

inherit cros-debug cros-workon platform user

DESCRIPTION="Chromium OS P2P"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="chromeos-base/metrics
	dev-libs/glib
	net-dns/avahi-daemon
	net-firewall/iptables"

DEPEND="${RDEPEND}"

platform_pkg_test() {
	local tests=(
		p2p-client-unittests
		p2p-server-unittests
		p2p-http-server-unittests
		p2p-common-unittests
	)

	local test_bin
	cd "${OUT}"
	for test_bin in "${tests[@]}"; do
		platform_test "run" "./${test_bin}"
	done
}

pkg_preinst() {
	# Groups are managed in the central account database.
	enewgroup p2p
	enewuser p2p
}

src_install() {
	dosbin "${OUT}"/p2p-client
	dosbin "${OUT}"/p2p-server
	dosbin "${OUT}"/p2p-http-server

	insinto /etc/init
	doins data/p2p.conf
}


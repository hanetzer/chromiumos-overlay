# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

DESCRIPTION="Init configuration to set up NAT and IP forwarding"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	net-firewall/iptables
"

S="${WORKDIR}"

src_install() {
	insinto /etc/init
	doins "${FILESDIR}"/nat.conf
}

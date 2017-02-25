# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

DESCRIPTION="Install scripts for setting up termina VMs"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
	chromeos-base/chromeos-nat-init
"

S="${WORKDIR}"

src_install() {
	insinto /etc/init
	doins "${FILESDIR}/vm-nat.conf"
}

# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

DESCRIPTION="Init script to run agetty on the serial port"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

DEPEND="!chromeos-base/tegra-debug"
RDEPEND="sys-apps/upstart"

src_install() {
    insinto /etc/init
    doins "${FILESDIR}"/etc/init/ttyS0.conf
}

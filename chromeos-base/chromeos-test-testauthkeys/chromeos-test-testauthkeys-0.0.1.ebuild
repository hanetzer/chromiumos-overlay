# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

DESCRIPTION="Install Chromium OS test public keys for ssh clients on test image"
HOMEPAGE="http://www.chromium.org/"
KEYWORDS="*"
LICENSE="BSD"
SLOT="0"
S="${WORKDIR}"

src_install() {
	dodir /root/.ssh
	cat "${FILESDIR}"/*.pub > "${D}"/root/.ssh/authorized_keys || die
}

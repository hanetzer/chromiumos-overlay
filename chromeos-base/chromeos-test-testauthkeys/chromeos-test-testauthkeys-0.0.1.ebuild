# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

DESCRIPTION="Install Chromium OS test public keys for ssh clients on test image"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

S="${WORKDIR}"

src_install() {
	dodir /root/.ssh
	cat "${FILESDIR}"/*.pub > "${D}"/root/.ssh/authorized_keys || die

	insinto /root/.ssh
	newins "${FILESDIR}/testing_rsa" id_rsa
	newins "${FILESDIR}/testing_rsa.pub" id_rsa.pub
	fperms 600 /root/.ssh/id_rsa
}

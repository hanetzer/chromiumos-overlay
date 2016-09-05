# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

inherit systemd

DESCRIPTION="Install the upstart job that creates the swap and zram."
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="systemd"

RDEPEND="
	sys-apps/util-linux
	"

S=${WORKDIR}

src_install() {
	if use systemd; then
		systemd_dounit "${FILESDIR}"/init/swap.service
		systemd_enable_service system-services.target swap.service
	else
		insinto /etc/init
		doins "${FILESDIR}"/init/*.conf
	fi
	insinto /usr/share/cros/init
	doins "${FILESDIR}"/init/swap.sh
}

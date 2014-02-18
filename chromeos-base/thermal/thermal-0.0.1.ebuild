# Copyright (c) 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

DESCRIPTION="Simple thermal throttling script"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

DEPEND=""
RDEPEND="
	!<chromeos-base/chromeos-bsp-daisy-0.0.1-r53
	!<chromeos-base/chromeos-bsp-pit-private-0.0.1-r15
	chromeos-base/chromeos-init
"

S=${WORKDIR}

src_install() {
	# Install platform specific config file for thermal monitoring
	dosbin "${FILESDIR}/thermal.sh"
	insinto "/etc/init/"
	doins "${FILESDIR}/thermal.conf"
}

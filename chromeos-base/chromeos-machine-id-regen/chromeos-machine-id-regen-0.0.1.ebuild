# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

DESCRIPTION="ChromeOS scripts to periodically update machine-id"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	>=sys-apps/dbus-1.6.8-r9
"

S="${WORKDIR}"

src_install() {
	# cros-machine-id-regen - http://crbug.com/431337
	dosbin "${FILESDIR}"/cros-machine-id-regen
	insinto /etc/init
	doins "${FILESDIR}"/cros-machine-id-regen-network.conf
	doins "${FILESDIR}"/cros-machine-id-regen-periodic.conf
}

# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# NOTE: This ebuild could be overridden in an overlay to provide a
# board-specific xorg.conf as necessary.

EAPI=2

DESCRIPTION="Board specific xorg configuration file."

LICENSE="BSD"
SLOT="0"
KEYWORDS="arm x86"
IUSE="synaptics multitouch"

RDEPEND=""

src_install() {
	insinto /etc/X11
	if use multitouch ; then
		newins "${FILESDIR}/xorg.conf-multitouch" xorg.conf
	elif use synaptics ; then
		newins "${FILESDIR}/xorg.conf-synaptics" xorg.conf
	else
		newins "${FILESDIR}/xorg.conf" xorg.conf
	fi
}

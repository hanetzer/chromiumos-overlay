# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# NOTE: This ebuild could be overridden in an overlay to provide a
# board-specific xorg.conf as necessary.

EAPI=2

DESCRIPTION="Board specific xorg configuration file."

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="synaptics multitouch mario cmt"

RDEPEND=""

src_install() {
	insinto /etc/X11
	newins "${FILESDIR}/xorg.conf" xorg.conf

	dodir /etc/X11/xorg.conf.d
	insinto /etc/X11/xorg.conf.d
	if use cmt ; then
		newins "${FILESDIR}/touchpad.conf-cmt" 50-touchpad-cmt.conf
	elif use multitouch ; then
		newins "${FILESDIR}/touchpad.conf-multitouch" 50-touchpad-multitouch.conf
	elif use synaptics ; then
		newins "${FILESDIR}/touchpad.conf-syntp" 50-touchpad-syntp.conf
	elif use mario ; then
		newins "${FILESDIR}/touchpad.conf-mario" 50-touchpad-mario.conf
	else
		newins "${FILESDIR}/touchpad.conf" 50-touchpad.conf
	fi
	newins "${FILESDIR}/20-mouse.conf" 20-mouse.conf
}

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
	# Since syntp does not use an evdev (/dev/input/event*) device nodes,
	# its .conf snippet can be installed alongside one of the evdev-compatible
	# xf86-input-* touchpad drivers.
	if use synaptics ; then
		newins "${FILESDIR}/touchpad.conf-syntp" 50-touchpad-syntp.conf
	fi
	# Enable exactly one evdev-compatible X input touchpad driver.
	if use cmt ; then
		newins "${FILESDIR}/touchpad.conf-cmt" 50-touchpad-cmt.conf
	elif use multitouch ; then
		newins "${FILESDIR}/touchpad.conf-multitouch" 50-touchpad-multitouch.conf
	elif use mario ; then
		newins "${FILESDIR}/touchpad.conf-synaptics-mario" 50-touchpad-synaptics.conf
	else
		newins "${FILESDIR}/touchpad.conf-synaptics" 50-touchpad-synaptics.conf
	fi
	newins "${FILESDIR}/20-mouse.conf" 20-mouse.conf
}

# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# NOTE: This ebuild could be overridden in an overlay to provide a
# board-specific xorg.conf as necessary.

EAPI=4
inherit cros-board

DESCRIPTION="Board specific xorg configuration file."

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="alex cmt elan mario multitouch synaptics -tegra"

RDEPEND=""
DEPEND="x11-base/xorg-server"

S=${WORKDIR}

src_install() {
	local board=$(get_current_board_no_variant)
	local board_variant=$(get_current_board_with_variant)

	insinto /etc/X11
	if ! use tegra; then
		doins "${FILESDIR}/xorg.conf"
	fi

	insinto /etc/X11/xorg.conf.d
	if use tegra; then
		doins "${FILESDIR}/tegra.conf"
	fi

	# Since syntp does not use evdev (/dev/input/event*) device nodes,
	# its .conf snippet can be installed alongside one of the
	# evdev-compatible xf86-input-* touchpad drivers.
	if use synaptics; then
		doins "${FILESDIR}/50-touchpad-syntp.conf"
	fi
	# Enable exactly one evdev-compatible X input touchpad driver.
	if use cmt; then
		doins "${FILESDIR}/50-touchpad-cmt.conf"
		if use elan; then
			doins "${FILESDIR}/50-touchpad-cmt-elan.conf"
		elif use alex; then
			doins "${FILESDIR}/50-touchpad-cmt-alex.conf"
		elif [ "${board}" = "x86-zgb" ]; then
			doins "${FILESDIR}/50-touchpad-cmt-zgb.conf"
		elif [ "${board_variant}" = "tegra2_aebl" ]; then
			doins "${FILESDIR}/50-touchpad-cmt-aebl.conf"
		elif [ "${board_variant}" = "tegra2_kaen" ]; then
			doins "${FILESDIR}/50-touchpad-cmt-kaen.conf"
		elif [[ "${board}" = "lumpy" || "${board}" = "lumpy64" ]]; then
			doins "${FILESDIR}/50-touchpad-cmt-lumpy.conf"
		fi
	elif use multitouch; then
		doins "${FILESDIR}/50-touchpad-multitouch.conf"
	elif use mario; then
		doins "${FILESDIR}/50-touchpad-synaptics-mario.conf"
	else
		doins "${FILESDIR}/50-touchpad-synaptics.conf"
	fi
	doins "${FILESDIR}/20-mouse.conf"
}

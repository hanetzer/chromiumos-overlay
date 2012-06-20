# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# NOTE: This ebuild could be overridden in an overlay to provide a
# board-specific xorg.conf as necessary.

EAPI=4
inherit cros-board

DESCRIPTION="Board specific xorg configuration file."

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="alex butterfly cmt elan -exynos mario multitouch stout synaptics -tegra -aura"

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
	elif use exynos; then
		doins "${FILESDIR}/exynos.conf"
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
		elif use butterfly; then
			doins "${FILESDIR}/50-touchpad-cmt-butterfly.conf"
		elif use stout; then
			doins "${FILESDIR}/50-touchpad-cmt-stout.conf"
		elif use mario; then
			doins "${FILESDIR}/50-touchpad-cmt-mario.conf"
		elif [[ "${board}" = "x86-zgb" || "${board}" = "x86-zgb32" ]]; then
			doins "${FILESDIR}/50-touchpad-cmt-zgb.conf"
		elif [ "${board_variant}" = "tegra2_aebl" ]; then
			doins "${FILESDIR}/50-touchpad-cmt-aebl.conf"
		elif [ "${board_variant}" = "tegra2_kaen" ]; then
			doins "${FILESDIR}/50-touchpad-cmt-kaen.conf"
		elif [[ "${board}" = "lumpy" || "${board}" = "lumpy64" ]]; then
			doins "${FILESDIR}/50-touchpad-cmt-lumpy.conf"
		elif [ "${board}" = "link" ]; then
			doins "${FILESDIR}/50-touchpad-cmt-link.conf"
		elif [ "${board}" = "daisy" ]; then
			doins "${FILESDIR}/50-touchpad-cmt-daisy.conf"
		fi
		if use aura; then
			doins "${FILESDIR}/50-touchpad-cmt-aura.conf"
		fi
	elif use multitouch; then
		doins "${FILESDIR}/50-touchpad-multitouch.conf"
	elif use mario; then
		doins "${FILESDIR}/50-touchpad-synaptics-mario.conf"
	else
		doins "${FILESDIR}/50-touchpad-synaptics.conf"
	fi
	doins "${FILESDIR}/20-mouse.conf"
	doins "${FILESDIR}/20-touchscreen.conf"
}

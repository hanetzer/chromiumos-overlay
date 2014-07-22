# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# NOTE: This ebuild could be overridden in an overlay to provide a
# board-specific xorg.conf as necessary.

EAPI=4
CROS_WORKON_COMMIT="d623c538e49b0372d9e4ab53e7967e0c5cc47919"
CROS_WORKON_TREE="75c00902432003cea78f1083562c6b7f55a5fa5d"
CROS_WORKON_PROJECT="chromiumos/platform/xorg-conf"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-board cros-workon user

DESCRIPTION="Board specific xorg configuration file."
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="alex butterfly elan -exynos mario stout -tegra -rk32"

RDEPEND="!chromeos-base/touchpad-linearity"
DEPEND="x11-base/xorg-server"

src_install() {
	local board=$(get_current_board_no_variant)
	local board_variant=$(get_current_board_with_variant)

	insinto /etc/X11
	if ! use tegra; then
		doins xorg.conf
	fi

	insinto /etc/X11/xorg.conf.d
	if use tegra; then
		doins tegra.conf
	elif use exynos; then
		doins exynos.conf
	elif use rk32; then
		doins rk32.conf
	fi

	# Enable exactly one evdev-compatible X input touchpad driver.
	#
	# Note: If possible, use the following xorg config names to allow
	# this ebuild to install them automatically:
	#    - 50-touchpad-cmt-$BOARD.conf
	#    - 60-touchpad-cmt-$BOARD_VARIANT.conf
	# e.g. daisy_skate will include the files:
	#    - 50-touchpad-cmt-daisy.conf
	#    - 60-touchpad-cmt-daisy_skate.conf
	doins 40-touchpad-cmt.conf
	if use elan; then
		doins 50-touchpad-cmt-elan.conf
	elif use alex; then
		doins 50-touchpad-cmt-alex.conf
	elif use butterfly; then
		doins 50-touchpad-cmt-butterfly.conf
	elif use stout; then
		doins 50-touchpad-cmt-stout.conf
	elif use mario; then
		doins 50-touchpad-cmt-mario.conf
	elif [[ "${board}" = "x86-zgb" || "${board}" = "x86-zgb32" ]]; then
		doins 50-touchpad-cmt-zgb.conf
	elif [ "${board_variant}" = "tegra2_aebl" ]; then
		doins 50-touchpad-cmt-aebl.conf
	elif [ "${board_variant}" = "tegra2_kaen" ]; then
		doins 50-touchpad-cmt-kaen.conf
	elif [[ "${board}" = "lumpy" || "${board}" = "lumpy64" ]]; then
		doins 50-touchpad-cmt-lumpy.conf
	elif [[ "${board}" = "daisy" && "${board_variant}" = "${board}" ]]; then
		doins 50-touchpad-cmt-daisy.conf
		doins 50-touchpad-cmt-pit.conf # Some Lucas's use Pit Touchpad module
	elif [ "${board_variant}" = "daisy_spring" ]; then
		doins 50-touchpad-cmt-spring.conf
	elif [ "${board_variant}" = "peach_pit" ]; then
		doins 50-touchpad-cmt-pit.conf
	elif [ "${board_variant}" = "peach_pi" ]; then
		doins 50-touchpad-cmt-pi.conf
	else
		if [ -f "50-touchpad-cmt-${board}.conf" ]; then
			doins "50-touchpad-cmt-${board}.conf"
		fi
		if [ -f "60-touchpad-cmt-${board_variant}.conf" ]; then
			doins "60-touchpad-cmt-${board_variant}.conf"
		fi
	fi
	doins 20-mouse.conf
	doins 20-touchscreen.conf

	insinto "/usr/share/gestures"
	case ${board} in
	lumpy|lumpy64)
		doins "files/lumpy_linearity.dat" ;;
	daisy)
		doins "files/daisy_linearity.dat" ;;
	esac
}

pkg_preinst() {
	enewuser "xorg"
	enewgroup "xorg"
}

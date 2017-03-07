# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="f7a00485784f1d159ae86492d70bd599e4389b2a"
CROS_WORKON_TREE="2161b124e4f35dfe6c9ca3a88a1e07b16a7eb700"
CROS_WORKON_LOCALNAME="xorg-conf"
CROS_WORKON_PROJECT="chromiumos/platform/xorg-conf"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-board cros-workon user

DESCRIPTION="Board specific gestures library configuration file."
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="alex butterfly elan mario stout ozone"

RDEPEND="!chromeos-base/touchpad-linearity
	!<=chromeos-base/xorg-conf-0.0.6-r128"
DEPEND=""

src_install() {
	local board=$(get_current_board_no_variant)
	local board_variant=$(get_current_board_with_variant)

	# Install to different directories depending on whether this is a
	# freon build or not. We use the same gesture library conf files
	# for freon builds so they are still needed there.
	if ! use ozone; then
		insinto /etc/X11/xorg.conf.d
	else
		insinto /etc/gesture
	fi

	# -cheets variants are running on the same hardware as their non-cheets
	# counterpart. Strip -cheets suffix to re-use the config.
	local board_variant=${board_variant%-cheets}
	local board=${board%-cheets}

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
	elif [[ "${board}" = "x86-zgb" ]]; then
		doins 50-touchpad-cmt-zgb.conf
	elif [[ "${board}" = "lumpy" ]]; then
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

	insinto "/usr/share/gestures"
	case ${board} in
	lumpy)
		doins "files/lumpy_linearity.dat" ;;
	daisy)
		doins "files/daisy_linearity.dat" ;;
	esac
}


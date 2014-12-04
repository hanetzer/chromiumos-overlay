# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

#
# Original Author: The Chromium OS Authors <chromium-os-dev@chromium.org>
# Purpose: Library for handling building of ChromiumOS packages
#
#

# @ECLASS-VARIABLE: EC_BOARDS
# @DESCRIPTION:
#  This class contains function that lists the name of embedded
#  controllers for a given system.
#  When found, the array EC_BOARDS is populated.
#  It no ECs are known or build host tools, bds toolchain is defined.
#  For example, for a falco machine, EC_BOARDS = [ "falco" ]
#  For samus, EC_BOARDS = [ "samus", "samus_pd" ]
#
#  The firmware for these ECs can be found in platform/ec/build
#  The first item of the array is always the main ec.
[[ ${EAPI} != "4" ]] && die "Only EAPI=4 is supported"

EC_BOARD_USE_PREFIX="ec_firmware_"

# EC firmware board names for overlay with special configuration
EC_BOARD_NAMES=(
	bds
	big
	blaze
	dingdong
	firefly
	hoho
	jerry
	kitty
	mighty
	minimuffin
	nyan
	pinky
	pit
	ryu
	ryu_p1
	ryu_sh
	samus
	samus_pd
	snow
	spring
	twinkie
	zinger
)

IUSE_FIRMWARES="${EC_BOARD_NAMES[@]/#/${EC_BOARD_USE_PREFIX}}"
IUSE="${IUSE_FIRMWARES} cros_host"

# Echo the current board, with variant.
get_ec_boards()
{
	EC_BOARDS=()
	if use cros_host; then
		# If we are building for the purpose of emitting host-side tools, assume
		# EC_BOARDS=(bds) for the build.
		EC_BOARDS+=(bds)
		return
	fi

	# Add board names requested by ec_firmware_* USE flags
	local ov_board=$(get_current_board_with_variant)
	local ec_board
	for ec_board in ${ov_board/#/${EC_BOARD_USE_PREFIX}} ${IUSE_FIRMWARES}; do
		use ${ec_board} && EC_BOARDS+=(${ec_board#${EC_BOARD_USE_PREFIX}})
	done

	# Allow building for boards that don't have an EC
	# (so we can compile test on bots for testing).
	if [[ ${#EC_BOARDS[@]} -eq 0 ]]; then
		# No explicit board name declared, try the overlay name
		if [[ ! -d board/${ov_board} ]] ; then
			ewarn "Sorry, ${ov_board} not supported; doing build-test with BOARD=bds"
			ov_board=bds
		fi
		EC_BOARDS=(${ov_board})
	fi
	einfo "Building for boards: ${EC_BOARDS[*]}"
}

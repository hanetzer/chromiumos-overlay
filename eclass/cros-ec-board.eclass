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

# Check for EAPI 4+
case "${EAPI:-0}" in
4|5|6) ;;
*) die "unsupported EAPI (${EAPI}) in eclass (${ECLASS})" ;;
esac

EC_BOARD_USE_PREFIX="ec_firmware_"
EC_EXTRA_BOARD_USE_PREFIX="ec_firmware_extra_"

# EC firmware board names for overlay with special configuration
EC_BOARD_NAMES=(
	bds
	chell
	chell_pd
	coral
	cr50
	cyan
	dingdong
	elm
	eve
	eve_fp
	fizz
	glados
	glados_pd
	gru
	hadoken
	hammer
	hoho
	host
	jerry
	kahlee
	kevin
	llama
	minimuffin
	oak
	oak_pd
	plankton
	poppy
	reef
	rowan
	ryu
	ryu_p4p5
	ryu_sh
	ryu_sh_loader
	samus
	samus_pd
	scarlet
	soraka
	staff
	strago
	twinkie
	zinger
	zoombini
)

IUSE_FIRMWARES="${EC_BOARD_NAMES[@]/#/${EC_BOARD_USE_PREFIX}}"
IUSE_EXTRA_FIRMWARES="${EC_BOARD_NAMES[@]/#/${EC_EXTRA_BOARD_USE_PREFIX}}"
IUSE="${IUSE_FIRMWARES} ${IUSE_EXTRA_FIRMWARES} cros_host unibuild"


# Echo the current boards
get_ec_boards()
{
	EC_BOARDS=()
	if use cros_host; then
		# If we are building for the purpose of emitting host-side tools, assume
		# EC_BOARDS=(bds) for the build.
		EC_BOARDS=(bds)
		return
	fi

	# Add board names requested by ec_firmware_* USE flags
	local ec_board
	if use unibuild; then
		# At present USE=unibuild is optional for all boards.
		# TODO(sjg): Should we be trying to enable multiple 'use'
		# flags here? If so, we would end up enabling use flags for
		# several models (e.g. reef when building reef
		# with USE=unibuild. But then where would we set these 'use'
		# flags? It should presumably be done in make.conf, but then
		# we need to set USE=unibuild there, meaning it is no-longer
		# optional.
		# On the other hand, doing it this way means that (I think)
		# we cannot detect a change like adding a new model to reef,
		# since there is no change in the defined USE flags.
		EC_BOARDS+=(${EC_FIRMWARE_UNIBUILD} ${EC_FIRMWARE_EXTRA_UNIBUILD})
	else
		for ec_board in ${IUSE_FIRMWARES}; do
			use ${ec_board} && EC_BOARDS+=(${ec_board#${EC_BOARD_USE_PREFIX}})
		done
		for ec_board in ${IUSE_EXTRA_FIRMWARES}; do
			use ${ec_board} && EC_BOARDS+=(${ec_board#${EC_EXTRA_BOARD_USE_PREFIX}})
		done
	fi

	# Allow building for boards that don't have an EC
	# (so we can compile test on bots for testing).
	if [[ ${#EC_BOARDS[@]} -eq 0 ]]; then
		EC_BOARDS=(bds)
	fi
	einfo "Building for boards: ${EC_BOARDS[*]}"
}

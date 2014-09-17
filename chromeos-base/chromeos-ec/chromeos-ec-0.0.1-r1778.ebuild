# Copyright (C) 2012 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE.makefile file.

EAPI="4"
CROS_WORKON_COMMIT="eff864775f25f16480955ebde7234219c6e03948"
CROS_WORKON_TREE="d4abaf804d6778885004c0423cbda45856569c55"
CROS_WORKON_PROJECT="chromiumos/platform/ec"
CROS_WORKON_LOCALNAME="ec"

inherit toolchain-funcs cros-board cros-workon

DESCRIPTION="Embedded Controller firmware code"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="arm amd64 x86"

USE_PREFIX="ec_firmware_"

# EC firmware board names for overlay with special configuration
EC_BOARD_NAMES=(
	bds
	big
	blaze
	firefly
	kitty
	nyan
	pit
	ryu
	ryu_sh
	samus
	samus_pd
	snow
	spring
	zinger
)

IUSE_FIRMWARES="${EC_BOARD_NAMES[@]/#/${USE_PREFIX}}"
IUSE="cros_host test utils ${IUSE_FIRMWARES}"

RDEPEND="dev-embedded/libftdi"
DEPEND="${RDEPEND}"

# We don't want binchecks since we're cross-compiling firmware images using
# non-standard layout.
RESTRICT="binchecks"

src_configure() {
	cros-workon_src_configure
}

set_build_env() {
	# The firmware is running on ARMv7-m (Cortex-M4)
	export CROSS_COMPILE=arm-none-eabi-
	tc-export CC BUILD_CC
	export HOSTCC=${CC}
	export BUILDCC=${BUILD_CC}

	if use cros_host; then
		# If we are building for the purpose of emitting host-side tools, assume
		# EC_BOARDS=(bds) for the build.
		EC_BOARDS=(bds)
	else
		local ov_board=$(get_current_board_with_variant)

		EC_BOARDS=()

		# Add board names requested by ec_firmware_* USE flags
		local ec_board
		for ec_board in ${ov_board/#/${USE_PREFIX}} ${IUSE_FIRMWARES}; do
			use ${ec_board} && EC_BOARDS+=(${ec_board#${USE_PREFIX}})
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
	fi
	einfo "Building for boards: ${EC_BOARDS[*]}"
}

src_compile() {
	set_build_env

	local board
	for board in "${EC_BOARDS[@]}"; do
		BOARD=${board} emake clean
		BOARD=${board} emake all
		BOARD=${board} emake tests

		BOARD=${board} emake all out=build/${board}_shifted \
				EXTRA_CFLAGS="-DSHIFT_CODE_FOR_TEST"
	done
}

#
# Install firmware binaries for a specific board.
#
# param $1 - the board name.
# param $2 - the output directory to install artifacts.
#
board_install() {
	insinto $2
	pushd build/$1 >/dev/null || die
	doins ec{,.RW}.bin
	newins ec.RO.flat ec.RO.bin
	# EC test binaries
	nonfatal doins test-*.bin || ewarn "No test binaries found"
	# Intermediate files for debugging
	doins ec.*.elf
	popd > /dev/null
	newins build/$1_shifted/ec.bin ec_autest_image.bin
}

src_install() {
	set_build_env

	# The first board should be the main EC
	local ec="${EC_BOARDS[0]}"

	# If we are building host-side tools, install flash_ec and stm32mon.
	if use cros_host || use utils; then
		dobin util/flash_ec
		dobin build/${ec}/util/stm32mon
	fi

	# Only install target binaries if not building for host
	if ! use cros_host; then
		# EC firmware binaries
		board_install ${ec} /firmware

		# Utilities
		dobin build/${ec}/util/ectool

		# Install additional firmwares
		local board
		for board in "${EC_BOARDS[@]}"; do
			board_install ${board} /firmware/${board}
		done
	fi
}

src_test() {
	emake runtests
}

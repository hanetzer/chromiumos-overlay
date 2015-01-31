# Copyright (C) 2012 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE.makefile file.

EAPI="4"
CROS_WORKON_COMMIT="d93544bbed59789f728527cb8c73f9997598130c"
CROS_WORKON_TREE="a9c727b8d25d341071eeef772c0cf0001f9f73f9"
CROS_WORKON_PROJECT="chromiumos/platform/ec"
CROS_WORKON_LOCALNAME="ec"

inherit toolchain-funcs cros-ec-board cros-workon

DESCRIPTION="Embedded Controller firmware code"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

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

	get_ec_boards
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
	grep -q "^CONFIG_FW_INCLUDE_RO=y" .config && newins ec.RO.flat ec.RO.bin
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

	# EC firmware binaries
	board_install ${ec} /firmware

	# Install additional firmwares
	local board
	for board in "${EC_BOARDS[@]}"; do
		board_install ${board} /firmware/${board}
	done
}

src_test() {
	emake runtests
}

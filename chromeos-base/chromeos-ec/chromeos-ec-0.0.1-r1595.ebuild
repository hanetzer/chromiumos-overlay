# Copyright (C) 2012 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE.makefile file.

EAPI="4"
CROS_WORKON_COMMIT="6ed3fe80b2c3320bb49dbb23286316d1a3d5616c"
CROS_WORKON_TREE="94175cf57f5c28e099a46de0cf7e78a71ef36bb9"
CROS_WORKON_PROJECT="chromiumos/platform/ec"
CROS_WORKON_LOCALNAME="ec"

inherit toolchain-funcs cros-board cros-workon

DESCRIPTION="Embedded Controller firmware code"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="arm amd64 x86"
IUSE="cros_host test bds nyan_big nyan_blaze peach_pit peach_pi skate snow spring"

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

	# Allow building for boards that don't have an EC
	# (so we can compile test on bots for testing).
	# Also, it is possible that we are building this package for
	# purposes of emitting the host-side tools, in which case let's
	# assume EC_BOARD=bds for purposes of this build.
	if use cros_host; then
		export EC_BOARD=bds
	else
		export EC_BOARD=$(usev bds || get_current_board_with_variant)
	fi
	# FIXME: hack to separate BOARD= used by EC Makefile and Portage,
	# crosbug.com/p/10377
	if use snow; then
		EC_BOARD=snow
	fi
	# If building for spring hack in spring, must happen after snow due
	# to hirearchy of current overlays.
	if use spring || use skate; then
		EC_BOARD=spring
	fi
	if use peach_pit || use peach_pi; then
		EC_BOARD=pit
	fi
	if use nyan_big; then
		EC_BOARD=big
	fi
	if use nyan_blaze; then
		EC_BOARD=blaze
	fi
	if [[ ! -d board/${EC_BOARD} ]] ; then
		ewarn "Sorry, ${EC_BOARD} not supported; doing build-test with BOARD=bds"
		EC_BOARD=bds
	else
		elog "Building for board ${EC_BOARD}"
	fi
}

src_compile() {
	set_build_env
	BOARD=${EC_BOARD} emake clean
	BOARD=${EC_BOARD} emake all
	BOARD=${EC_BOARD} emake tests

	EXTRA_ARGS="out=build/${EC_BOARD}_shifted "
	EXTRA_ARGS+="EXTRA_CFLAGS=\"-DSHIFT_CODE_FOR_TEST\""
	BOARD=${EC_BOARD} emake all ${EXTRA_ARGS}
}

src_install() {
	set_build_env

	# If we are building host-side tools, install flash_ec and stm32mon
	# rather than target-specific binaries.
	if use cros_host; then
		dobin util/flash_ec
		dobin build/${EC_BOARD}/util/stm32mon
	else
		# EC firmware binaries
		insinto /firmware
		doins build/${EC_BOARD}/ec.bin
		doins build/${EC_BOARD}/ec.RW.bin
		newins build/${EC_BOARD}/ec.RO.flat ec.RO.bin
		newins build/${EC_BOARD}_shifted/ec.bin ec_autest_image.bin
		# EC test binaries
		if ls build/${EC_BOARD}/test-*.bin &>/dev/null ; then
			doins build/${EC_BOARD}/test-*.bin
		else
			ewarn "No test binaries found"
		fi
		# Intermediate files for debugging
		doins build/${EC_BOARD}/ec.*.elf
		# Utilities
		exeinto /usr/bin
		doexe build/${EC_BOARD}/util/ectool
	fi
}

src_test() {
	emake runtests
}

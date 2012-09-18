# Copyright (C) 2012 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE.makefile file.
CROS_WORKON_COMMIT=72948eaf4e7829ee5af59f2d7e3edd0b983723ef
CROS_WORKON_TREE="283ca00e54c949688d46fc0d81fe6ebb89f90b80"

EAPI="4"
CROS_WORKON_PROJECT="chromiumos/platform/ec"
CROS_WORKON_LOCALNAME="ec"

inherit toolchain-funcs cros-board cros-workon

DESCRIPTION="Embedded Controller firmware code"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="arm amd64 x86"
IUSE="test bds snow"

# We don't want binchecks since we're cross-compiling firmware images using
# non-standard layout.
RESTRICT="binchecks"

set_build_env() {
	# The firmware is running on ARMv7-m (Cortex-M4)
	export CROSS_COMPILE=arm-none-eabi-
	tc-export CC BUILD_CC
	export HOSTCC=${CC}
	export BUILDCC=${BUILD_CC}

	# Allow building for boards that don't have an EC
	# (so we can compile test on bots for testing).
	export EC_BOARD=$(usev bds || get_current_board_with_variant)
	if [[ ! -d board/${EC_BOARD} ]] ; then
		ewarn "Sorry, ${EC_BOARD} not supported; doing build-test with BOARD=bds"
		EC_BOARD=bds
	fi

	# FIXME: hack to separate BOARD= used by EC Makefile and Portage,
	# crosbug.com/p/10377
	if use snow; then
		EC_BOARD=snow
	fi
}

src_compile() {
	set_build_env
	BOARD=${EC_BOARD} emake all

	EXTRA_ARGS="out=build/${EC_BOARD}_shifted "
	EXTRA_ARGS+="EXTRA_CFLAGS=\"-DSHIFT_CODE_FOR_TEST\""
	BOARD=${EC_BOARD} emake all ${EXTRA_ARGS}
}

src_install() {
	set_build_env
	# EC firmware binaries
	insinto /firmware
	doins build/${EC_BOARD}/ec.bin
	doins build/${EC_BOARD}/ec.RW.bin
	newins build/${EC_BOARD}/ec.RO.flat ec.RO.bin
	newins build/${EC_BOARD}_shifted/ec.bin ec_autest_image.bin
	# Intermediate files for debugging
	doins build/${EC_BOARD}/ec.*.elf
	# Utilities
	exeinto /usr/bin
	doexe build/${EC_BOARD}/util/ectool
}

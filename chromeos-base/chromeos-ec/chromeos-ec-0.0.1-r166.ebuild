# Copyright (C) 2012 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE.makefile file.
CROS_WORKON_COMMIT="d85fa75275ef92c05d07d57f62004f79e816b7a5"
CROS_WORKON_TREE="cc23385711ce12070bcd8cce3f3e8b00111e7b93"

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
IUSE="test bds"

set_build_env() {
	# The firmware is running on ARMv7-m (Cortex-M4)
	export CROSS_COMPILE=arm-none-eabi-
	tc-export CC BUILD_CC
	export HOSTCC=${CC}
	export BUILDCC=${BUILD_CC}

	# Allow building for boards that don't have an EC
	# (so we can compile test on bots for testing).
	export BOARD=$(usev bds || get_current_board_with_variant)
	if [[ ! -d board/${BOARD} ]] ; then
		ewarn "Sorry, ${BOARD} not supported; doing build-test with BOARD=bds"
		BOARD=bds
	fi
}

src_compile() {
	set_build_env
	emake all
}

src_test() {
	set_build_env
	# TODO(vpalatin) Enable once the qemu build is ready.
	#emake tests
	#emake qemu-tests
}

src_install() {
	set_build_env
	# EC firmware binary
	insinto /firmware
	doins build/${BOARD}/ec.bin
	# Firmware disassembly for debugging
	doins build/${BOARD}/ec.*.dis
	# Utilities
	exeinto /usr/bin
	doexe build/${BOARD}/util/ectool
}

# Copyright (C) 2012 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE.makefile file.
CROS_WORKON_COMMIT="cca78cfcfdda7700dc3e5659ef68cadedaef136b"
CROS_WORKON_TREE="5fc4467424c761d662aebf62a337a2dd24ccfb8d"

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
	# Intermediate files for debugging
	doins build/${BOARD}/ec.*.elf
	# Utilities
	exeinto /usr/bin
	doexe build/${BOARD}/util/ectool
}

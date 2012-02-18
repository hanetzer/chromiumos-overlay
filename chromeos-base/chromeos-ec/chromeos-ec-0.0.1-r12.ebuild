# Copyright (C) 2012 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE.makefile file.

EAPI=4
CROS_WORKON_COMMIT="ed9a5a55737df70bd926e91036d2e4730be38fec"
CROS_WORKON_PROJECT="chromiumos/platform/ec"

KEYWORDS="arm amd64 x86"

inherit toolchain-funcs cros-board cros-workon

DESCRIPTION="Embedded Controller firmware code"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
IUSE="test bds"

CROS_WORKON_LOCALNAME="ec"

set_build_env() {
	# The firmware is running on ARMv7-m (Cortex-M4)
	export CROSS_COMPILE=arm-none-eabi-
	tc-export CC BUILD_CC
	export HOSTCC=${CC}
	export BUILDCC=${BUILD_CC}
	if [[ "$(get_current_board_with_variant)" == *generic ]] ; then
		export BOARD=bds
	else
		export BOARD=$(usev bds || echo $(get_current_board_with_variant))
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

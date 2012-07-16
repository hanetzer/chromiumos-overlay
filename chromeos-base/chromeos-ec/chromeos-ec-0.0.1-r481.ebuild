# Copyright (C) 2012 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE.makefile file.
CROS_WORKON_COMMIT=3b0e13173dc5f082488b7fa1fe774222ea6fa983
CROS_WORKON_TREE="a77fded6b0a57abb4790f10f123c6996912f1669"

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
	doins build/${EC_BOARD}/ec.bin
	# Intermediate files for debugging
	doins build/${EC_BOARD}/ec.*.elf
	# Utilities
	exeinto /usr/bin
	doexe build/${EC_BOARD}/util/ectool
}

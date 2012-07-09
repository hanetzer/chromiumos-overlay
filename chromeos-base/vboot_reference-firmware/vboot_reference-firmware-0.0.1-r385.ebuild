# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="edea097d55771083fd17075f2cc2c8c7a5449914"
CROS_WORKON_TREE="4ec108d975f2295fd1733cc8a760cfa3e743f93b"

inherit cros-debug cros-workon toolchain-funcs

DESCRIPTION="Chrome OS verified boot library (firmware build mode)"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="-vb_mock_tpm"
EAPI="2"
CROS_WORKON_PROJECT="chromiumos/platform/vboot_reference"

DEPEND="chromeos-base/vboot_reference"

CROS_WORKON_LOCALNAME=vboot_reference

src_configure() {
	tc-export CC AR CXX

	export FIRMWARE_ARCH="$(tc-arch-kernel)"

	# Firmware related binaries are compiled in 32-bit toolchain on 64-bit platforms
	if [[ "${FIRMWARE_ARCH}" == "x86_64" ]]  ; then
		export FIRMWARE_ARCH="i386"
		prefix="i686-pc-linux-gnu-"
		export CC=${prefix}gcc
		export CXX=${prefix}g++
		export AR=${prefix}ar
	fi
}

src_compile() {
	local err_msg="${PN} compile failed. "
	err_msg+="Try running 'make clean' in the package root directory"

	local DEBUG=""
	if use cros-debug ; then
		DEBUG="DEBUG=1"
	fi

	local MOCK_TPM=""
	if use vb_mock_tpm ; then
		MOCK_TPM="MOCK_TPM=1"
	fi

	# Vboot reference knows the flags to use
	unset CFLAGS
	emake FIRMWARE_ARCH="${FIRMWARE_ARCH}" ${DEBUG} ${MOCK_TPM} || \
		die "${err_msg}"
}

src_install() {
	# Install vboot_fw.a to /build/${BOARD}/usr/lib
	insinto /usr/lib
	doins "${S}"/build/vboot_fw.a
}

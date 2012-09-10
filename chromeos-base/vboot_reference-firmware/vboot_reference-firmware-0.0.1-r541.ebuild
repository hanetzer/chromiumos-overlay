# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT=c92c81ecf517536d29da3cc75e4ea4d922cb28e2
CROS_WORKON_TREE="5cccf4ef328ac589180150c1a9fefb5966ab127e"

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

# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

inherit cros-debug cros-workon toolchain-funcs

DESCRIPTION="Chrome OS verified boot library (firmware build mode)"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="arm x86"
IUSE="-vb_mock_tpm"
EAPI="2"
CROS_WORKON_COMMIT="fa9d7782e837848a1aeb0e95295fa48ac23f7a26"
CROS_WORKON_PROJECT="chromiumos/platform/vboot_reference"

DEPEND="chromeos-base/vboot_reference"

CROS_WORKON_LOCALNAME=vboot_reference

src_compile() {
	tc-export CC AR CXX

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

	emake FIRMWARE_ARCH="$(tc-arch-kernel)" ${DEBUG} ${MOCK_TPM} || \
		die "${err_msg}"
}

src_install() {
	einfo "Installing header files and libraries"

	# Install firmware/include to /build/${BOARD}/usr/include/vboot
	local dst_dir='/usr/include/vboot'
	dodir "${dst_dir}"
	insinto "${dst_dir}"
	doins -r firmware/include/*

	# Install vboot_fw.a to /build/${BOARD}/usr/lib
	insinto /usr
	dolib.a "${S}"/build/vboot_fw.a
}

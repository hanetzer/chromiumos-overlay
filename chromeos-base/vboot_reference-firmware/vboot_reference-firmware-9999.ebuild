# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

inherit cros-workon

DESCRIPTION="Chrome OS verified boot library (firmware build mode)"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~arm"
IUSE="debug"
EAPI="2"

DEPEND=""

CROS_WORKON_PROJECT=vboot_reference
CROS_WORKON_LOCALNAME=vboot_reference

src_compile() {
	tc-export CC AR CXX

	local err_msg="${PN} compile failed. "
	err_msg+="Try running 'make clean' in the package root directory"

	local DEBUG=""
	if use debug ; then
		DEBUG=1
	fi

	emake FIRMWARE_ARCH="arm" DEBUG="${DEBUG}" || die "${err_msg}"
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

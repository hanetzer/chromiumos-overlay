# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

inherit eutils toolchain-funcs git

DESCRIPTION="Chrome OS verified boot tools"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE="minimal"
EAPI="2"

DEPEND="dev-libs/openssl
        sys-apps/util-linux"

EGIT_REPO_URI=git://chromiumos-git/git/repos/not-yet-populated.git
SRCPATH=src/platform/vboot_reference

src_unpack() {
	if [ -z "${CHROMEOS_ROOT}" ] ; then
		local CHROMEOS_ROOT=$(eval echo -n ~${SUDO_USER}/trunk)
	fi
        if [ -e "${CHROMEOS_ROOT}/${SRCPATH}" ] ; then
		cp -a "${CHROMEOS_ROOT}/${SRCPATH}" "${S}" || die
	else
		git_src_unpack
	fi
}


src_compile() {
	tc-export CC AR CXX
	emake || die "${SRCPATH} compile failed."
}

src_install() {
	if use minimal ; then
        	emake DESTDIR="${D}/usr/bin" -C cgpt install || \
	        	die "${SRCPATH} install failed."
	else                 
        	emake DESTDIR="${D}/usr/bin" install || \
	        	die "${SRCPATH} install failed."
	fi
}

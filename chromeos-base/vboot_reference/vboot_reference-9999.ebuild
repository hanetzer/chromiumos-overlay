# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

inherit cros-workon

DESCRIPTION="Chrome OS verified boot tools"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="minimal"
EAPI="2"

DEPEND="dev-libs/openssl
        sys-apps/util-linux"

EGIT_REPO_URI=git://chromiumos-git/git/repos/not-yet-populated.git
SRCPATH=src/platform/vboot_reference

src_compile() {
	tc-export CC AR CXX
	err_msg="${SRCPATH} compile failed. "
	err_msg+="Try running 'make clean' in the package root directory"
	emake || die "${err_msg}"
}

src_install() {
	if use minimal ; then
        	emake DESTDIR="${D}/usr/bin" BUILD="${S}"/build -C cgpt \
		      install || die "${SRCPATH} install failed."
	else
        	emake DESTDIR="${D}/usr/bin" install || \
	        	die "${SRCPATH} install failed."
	fi
}

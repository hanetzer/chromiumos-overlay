# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="7ec2bb6a4c91f8573be981812b1f58868198b259"
inherit cros-workon

DESCRIPTION="Chrome OS Boot Time Statistics Utilities"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE=""

RDEPEND=""

DEPEND=""

src_compile() {
	tc-export CC AR PKG_CONFIG
	emake || die "bootstat compile failed."
}

src_install() {
	into /
	dosbin bootstat || die
}

# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="043fba1c35f89cce95f804bf6d4f01cfc23a6c21"
CROS_WORKON_TREE="991766d064f618e8581a600647bdb8fdf0bfc189"
CROS_WORKON_PROJECT="chromiumos/third_party/cypress-tools"
CROS_WORKON_LOCALNAME=../third_party/cypress-tools
CROS_WORKON_SUBDIR=

inherit toolchain-funcs cros-workon

DESCRIPTION="Cypress APA Trackpad Firmware Update Utility"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE=""

RDEPEND=""
DEPEND=""

src_configure() {
	cros-workon_src_configure
}

src_compile() {
	tc-export CC
	emake || die "Compile failed"
}

src_install() {
	into /
	dosbin cyapa_fw_update

	insinto /opt/google/touchpad/cyapa
	doins images/CYTRA*
}

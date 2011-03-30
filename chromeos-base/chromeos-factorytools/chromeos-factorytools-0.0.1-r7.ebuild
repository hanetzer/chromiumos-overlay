# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="176670f2f8921fe5204408671b1f53d6cb9a32f1"

inherit cros-workon

DESCRIPTION="Chrome OS Factory Test Tools"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

DEPEND=""
RDEPEND="dev-lang/python
         >=chromeos-base/vpd-0.0.1-r11"

CROS_WORKON_LOCALNAME="factory_test_tools"
CROS_WORKON_PROJECT="factory_test_tools"

src_install() {
	dodir /usr/gooftool
	insinto /usr/gooftool
	exeinto /usr/gooftool
	doins *.png
	doexe gooftool *.sh *.py
}

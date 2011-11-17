# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="c1962f71dad5b560e03d9d413372f42c8308dd75"
CROS_WORKON_PROJECT="chromiumos/platform/factory_test_tools"

inherit cros-workon

DESCRIPTION="Chrome OS Factory Test Tools"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

DEPEND=""
RDEPEND="dev-lang/python
         >=chromeos-base/vpd-0.0.1-r11"

CROS_WORKON_LOCALNAME="factory_test_tools"

src_install() {
	dodir /usr/gooftool
	insinto /usr/gooftool
	exeinto /usr/gooftool
	doins *.png
	doexe gooftool *.sh *.py
}

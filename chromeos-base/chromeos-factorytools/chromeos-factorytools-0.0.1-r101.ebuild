# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="3cbd7ee3545880662e2d1822a2b2352be30154c6"
CROS_WORKON_TREE="f037d1caad4bc2f8d51efc6282b98aeda95223aa"

EAPI=4
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
	insinto /usr/local/factory/bin
	exeinto /usr/local/factory/bin
	doexe gooftool *.sh *.py
	doins *.png
	# Install symlink files
	doins edid hwid_tool
	# TODO(hungte) Remove following legacy folders after we've changed all
	# reference of gooftool into /usr/loca/factory/bin (ex, R20).
	dosym factory/bin /usr/local/gooftool
}

# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_PROJECT="chromiumos/platform/factory"

inherit cros-workon

DESCRIPTION="Chrome OS Factory Tools and Data"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

DEPEND=""
RDEPEND="!chromeos-base/chromeos-factorytools
         dev-lang/python
         >=chromeos-base/vpd-0.0.1-r11"

CROS_WORKON_LOCALNAME="factory"

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

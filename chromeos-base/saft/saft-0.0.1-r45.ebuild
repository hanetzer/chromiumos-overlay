# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="d35d3bec6f11ea903a02e51cc19e79d758e72c2c"
CROS_WORKON_TREE="1bbf84561951e3ccb0bb78755459bd808f102aed"

EAPI="4"
CROS_WORKON_PROJECT="chromiumos/platform/saft"

inherit cros-workon

DESCRIPTION="ChromeOS SAFT installer"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

RDEPEND="chromeos-base/vboot_reference
	virtual/chromeos-firmware"

src_install() {
	exeinto /usr/sbin/firmware/saft
	doexe *.{py,sh}
}

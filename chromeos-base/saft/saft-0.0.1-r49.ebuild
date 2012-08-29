# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="ed52297f365bf036cc9959ebd595c1833d1c0ce2"
CROS_WORKON_TREE="8a4457c536e036c291ae92198346584139d65af2"

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

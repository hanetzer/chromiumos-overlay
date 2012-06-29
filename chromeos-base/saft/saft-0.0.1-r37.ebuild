# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="e41125e7c4704af9bcf4f13c9b885baa05427e91"
CROS_WORKON_TREE="92f03abc31feb12ca028268e38b55632dc897287"

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

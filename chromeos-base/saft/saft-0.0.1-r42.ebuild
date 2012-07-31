# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT=e903dffd3a8f88cd57e4059ad66888277b36f7e0
CROS_WORKON_TREE="1f39b7cce54a5e06f14dcd75a6b5bcf1b3bef5db"

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

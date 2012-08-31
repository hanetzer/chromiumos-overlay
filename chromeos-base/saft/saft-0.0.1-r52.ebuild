# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT=80fbf0eabf78bfe4f8014414d4d6948edba8986d
CROS_WORKON_TREE="64d4ce95b131d47af2b63f608f83213e6cc31738"

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

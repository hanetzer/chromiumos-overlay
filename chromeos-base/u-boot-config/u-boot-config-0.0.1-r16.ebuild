# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="cd89cc05bbafbaa10d4d39428505a8d11bd6d2b0"
CROS_WORKON_PROJECT="chromiumos/platform/u-boot-config"

DESCRIPTION="ChromeOS specific U-Boot configurations"
HOMEPAGE="http://chromium.org"
LICENSE="BSD"
SLOT="0"
KEYWORDS="arm"
IUSE=""

RDEPEND=""
DEPEND=""

# This must be inherited *after* EGIT/CROS_WORKON variables defined
inherit cros-workon

src_install() {
	local arch=$(echo ${CHROMEOS_U_BOOT_CONFIG} | cut -d_ -f2)
	local board=${arch}/$(echo ${CHROMEOS_U_BOOT_CONFIG} | cut -d_ -f3)

	for directory in . ${arch} ${arch}/parts ${board} ${board}/parts; do
		dodir /u-boot/configs/chromeos/${directory}
		insinto /u-boot/configs/chromeos/${directory}

		doins ${directory}/* || die
	done
}

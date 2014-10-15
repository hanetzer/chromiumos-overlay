#Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

inherit cros-board

DESCRIPTION="Tegra mts firmware"
SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${P}.tbz2"

LICENSE="NVIDIA-r2"
SLOT="0"
KEYWORDS="-* arm"
IUSE=""

S=${WORKDIR}

src_install() {
	local board=$(get_current_board_with_variant)
	insinto /firmware/coreboot-private/3rdparty/mainboard/google/${board}
	doins mts_preboot_si
	doins mts_si
}

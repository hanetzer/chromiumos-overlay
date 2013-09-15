# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_PROJECT="chromiumos/third_party/linux-firmware"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-workon

DESCRIPTION="Firmware images from the upstream linux-fimware package"
HOMEPAGE="https://git.kernel.org/cgit/linux/kernel/git/firmware/linux-firmware.git/"

LICENSE="linux_firmware_ibt-hw? ( LICENCE.ibt_firmware )
	linux_firmware_iwlwifi-7260? ( LICENCE.iwlwifi_firmware )
	linux_firmware_marvell-pcie8897? ( LICENCE.Marvell )"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE_LINUX_FIRMWARE=(
	ibt-hw
	iwlwifi-7260
	marvell-pcie8897
)

DEPEND="linux_firmware_marvell-pcie8897? ( !net-wireless/marvell_sd8787[pcie] )"

IUSE="${IUSE_LINUX_FIRMWARE[@]/#/linux_firmware_}"

RESTRICT="binchecks strip test"

FIRMWARE_INSTALL_ROOT="/lib/firmware"

use_fw() {
	use linux_firmware_$1
}

doins_subdir() {
	# Avoid having this insinto command affecting later doins calls.
	local file
	for file in "${@}"; do
		(
		insinto "${FIRMWARE_INSTALL_ROOT}/${file%/*}"
		doins "${file}"
		)
	done
}

src_install() {
	insinto "${FIRMWARE_INSTALL_ROOT}"
	use_fw ibt-hw && doins_subdir intel/ibt-hw-*.bseq
	use_fw iwlwifi-7260 && doins iwlwifi-7260-*.ucode
	use_fw marvell-pcie8897 && doins_subdir mrvl/pcie8897_uapsta.bin
}

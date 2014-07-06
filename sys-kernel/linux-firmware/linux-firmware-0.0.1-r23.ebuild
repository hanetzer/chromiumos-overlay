# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="e5885a83a2f5518a26b8371784b7f06fb97603f3"
CROS_WORKON_TREE="b40d4668d3aef580c12601a1bf0542edaf5e5eca"
CROS_WORKON_PROJECT="chromiumos/third_party/linux-firmware"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-workon

DESCRIPTION="Firmware images from the upstream linux-fimware package"
HOMEPAGE="https://git.kernel.org/cgit/linux/kernel/git/firmware/linux-firmware.git/"

SLOT="0"
KEYWORDS="*"

IUSE_IWLWIFI=(
	iwlwifi-all
	iwlwifi-100
	iwlwifi-105
	iwlwifi-135
	iwlwifi-1000
	iwlwifi-1000
	iwlwifi-2000
	iwlwifi-2030
	iwlwifi-3160
	iwlwifi-3945
	iwlwifi-4965
	iwlwifi-5000
	iwlwifi-5150
	iwlwifi-6000
	iwlwifi-6005
	iwlwifi-6030
	iwlwifi-6050
	iwlwifi-7260
)
IUSE_BRCMWIFI=(
	brcmfmac-all
	brcmfmac4354-sdio
	brcmfmac4356-pcie
)
IUSE_LINUX_FIRMWARE=(
	ath9k_htc
	fw_sst
	ibt-hw
	"${IUSE_IWLWIFI[@]}"
	"${IUSE_BRCMWIFI[@]}"
	marvell-pcie8897
)
IUSE="${IUSE_LINUX_FIRMWARE[@]/#/linux_firmware_} video_cards_radeon"
LICENSE="linux_firmware_ath9k_htc? ( LICENCE.atheros_firmware )
	linux_firmware_fw_sst? ( LICENCE.fw_sst )
	linux_firmware_ibt-hw? ( LICENCE.ibt_firmware )
	linux_firmware_marvell-pcie8897? ( LICENCE.Marvell )
	$(printf 'linux_firmware_%s? ( LICENCE.iwlwifi_firmware ) ' "${IUSE_IWLWIFI[@]}")
	$(printf 'linux_firmware_%s? ( LICENCE.broadcom_bcm43xx ) ' "${IUSE_BRCMWIFI[@]}")
	video_cards_radeon? ( LICENSE.radeon )
"

DEPEND="linux_firmware_marvell-pcie8897? ( !net-wireless/marvell_sd8787[pcie] )
	!net-wireless/iwl1000-ucode
	!net-wireless/iwl2000-ucode
	!net-wireless/iwl2030-ucode
	!net-wireless/iwl3945-ucode
	!net-wireless/iwl4965-ucode
	!net-wireless/iwl5000-ucode
	!net-wireless/iwl6000-ucode
	!net-wireless/iwl6005-ucode
	!net-wireless/iwl6030-ucode
	!net-wireless/iwl6050-ucode
"
RDEPEND="${DEPEND}"

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
	local x
	insinto "${FIRMWARE_INSTALL_ROOT}"
	use_fw ath9k_htc && doins htc_*.fw
	use_fw fw_sst && doins_subdir intel/fw_sst*
	use_fw ibt-hw && doins_subdir intel/ibt-hw-*.bseq
	use_fw marvell-pcie8897 && doins_subdir mrvl/pcie8897_uapsta.bin
	use video_cards_radeon && doins_subdir radeon/*

	# The Intel wireless firmware is mostly standard.
	for x in "${IUSE_IWLWIFI[@]}"; do
		use_fw ${x} || continue
		case ${x} in
		iwlwifi-all)  doins iwlwifi-*.ucode ;;
		iwlwifi-6005) doins iwlwifi-6000g2a-*.ucode ;;
		iwlwifi-6030) doins iwlwifi-6000g2b-*.ucode ;;
		iwlwifi-*)    doins ${x}-*.ucode ;;
		esac
	done

	for x in "${IUSE_BRCMWIFI[@]}"; do
		use_fw ${x} || continue
		case ${x} in
		brcmfmac-all)      doins_subdir brcm/brcmfmac* ;;
		brcmfmac4354-sdio) doins_subdir brcm/brcmfmac4354-sdio.* ;;
		brcmfmac4356-pcie) doins_subdir brcm/brcmfmac4356-pcie.* ;;
		esac
	done
}

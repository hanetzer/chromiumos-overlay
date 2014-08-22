# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="e2eed96b7521d70abd1678d9a6713908bec4ed34"
CROS_WORKON_TREE="51af01d9438056b2d90d66b1cbd54e3e6c705d5a"
CROS_WORKON_PROJECT="chromiumos/third_party/linux-firmware"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-workon

DESCRIPTION="Firmware images from the upstream linux-fimware package"
HOMEPAGE="https://git.kernel.org/cgit/linux/kernel/git/firmware/linux-firmware.git/"

SLOT="0"
KEYWORDS="*"

IUSE_ATH3K=(
	ath3k-all
	ath3k-ar3011
	ath3k-ar3012
)
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
	iwlwifi-7265
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
	"${IUSE_ATH3K[@]}"
	"${IUSE_IWLWIFI[@]}"
	"${IUSE_BRCMWIFI[@]}"
	marvell-pcie8897
)
IUSE="${IUSE_LINUX_FIRMWARE[@]/#/linux_firmware_} video_cards_radeon"
LICENSE="
	linux_firmware_ath3k-all? ( LICENCE.atheros_firmware )
	linux_firmware_ath3k-ar3011? ( LICENCE.atheros_firmware )
	linux_firmware_ath3k-ar3012? ( LICENCE.atheros_firmware )
	linux_firmware_ath9k_htc? ( LICENCE.atheros_firmware )
	linux_firmware_fw_sst? ( LICENCE.fw_sst )
	linux_firmware_ibt-hw? ( LICENCE.ibt_firmware )
	linux_firmware_marvell-pcie8897? ( LICENCE.Marvell )
	$(printf 'linux_firmware_%s? ( LICENCE.iwlwifi_firmware ) ' "${IUSE_IWLWIFI[@]}")
	$(printf 'linux_firmware_%s? ( LICENCE.broadcom_bcm43xx ) ' "${IUSE_BRCMWIFI[@]}")
	video_cards_radeon? ( LICENSE.radeon )
"

DEPEND="linux_firmware_marvell-pcie8897? ( !net-wireless/marvell_sd8787[pcie] )
	linux_firmware_ath3k-all? ( !net-wireless/ath3k )
	linux_firmware_ath3k-ar3011? ( !net-wireless/ath3k )
	linux_firmware_ath3k-ar3012? ( !net-wireless/ath3k )
	!net-wireless/ath6k
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

	# The firmware here is a mess; install specific files by hand.
	if use linux_firmware_ath3k-all || use linux_firmware_ath3k-ar3011; then
		doins ath3k-1.fw
	fi
	if use linux_firmware_ath3k-all || use linux_firmware_ath3k-ar3012; then
		(
		insinto "${FIRMWARE_INSTALL_ROOT}/ar3k"
		doins ar3k/*.dfu
		)
	fi

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

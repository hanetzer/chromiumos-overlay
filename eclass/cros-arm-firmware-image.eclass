# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

#
# Original Author: The Chromium OS Authors <chromium-os-dev@chromium.org>
# Purpose: Library for generating ARM firmware image
#

# @ECLASS-VARIABLE: CROS_ARM_FIRMWARE_IMAGE_BCT
# @DESCRIPTION
# Location of the board-specific bct file
: ${CROS_ARM_FIRMWARE_IMAGE_BCT:=${ROOT%/}/u-boot/bct/board.bct}

# @ECLASS-VARIABLE: CROS_ARM_FIRMWARE_IMAGE_DEVKEYS
# @DESCRIPTION
# Location of the devkeys
: ${CROS_ARM_FIRMWARE_IMAGE_DEVKEYS=${ROOT%/}/usr/share/vboot/devkeys}

# @ECLASS-VARIABLE: CROS_ARM_FIRMWARE_IMAGE_SYSTEM_MAP
# @DESCRIPTION
# Location of the u-boot symbol table
: ${CROS_ARM_FIRMWARE_IMAGE_SYSTEM_MAP=${ROOT%/}/u-boot/System.map}

# @ECLASS-VARIABLE: CROS_ARM_FIRMWARE_IMAGE_AUTOCONF
# @DESCRIPTION
# Location of the u-boot configuration file
: ${CROS_ARM_FIRMWARE_IMAGE_AUTOCONF=${ROOT%/}/u-boot/autoconf.mk}

# @ECLASS-VARIABLE: CROS_ARM_FIRMWARE_IMAGE_LAYOUT_CONFIG
# @DESCRIPTION
# Location of the firmware image layout config
: ${CROS_ARM_FIRMWARE_IMAGE_LAYOUT_CONFIG=${FILESDIR}/firmware_layout_config}

# @ECLASS-VARIABLE: CROS_ARM_FIRMWARE_IMAGE_LAYOUT
# @DESCRIPTION
# Location of the generated layout
: ${CROS_ARM_FIRMWARE_IMAGE_LAYOUT=layout.py}

# @ECLASS-VARIABLE: CROS_ARM_FIRMWARE_IMAGE_SCREEN_CONFIG
# @DESCRIPTION
# Location of the screen configuration
: ${CROS_ARM_FIRMWARE_IMAGE_SCREEN_CONFIG=${FILESDIR}/firmware_screen_config.yaml}

# @ECLASS-VARIABLE: CROS_ARM_FIRMWARE_IMAGE_*_IMAGE
# @DESCRIPTION
# Location of the u-boot variants
: ${CROS_ARM_FIRMWARE_IMAGE_STUB_IMAGE=${ROOT%/}/u-boot/u-boot-stub.bin}
: ${CROS_ARM_FIRMWARE_IMAGE_RECOVERY_IMAGE=${ROOT%/}/u-boot/u-boot-recovery.bin}
: ${CROS_ARM_FIRMWARE_IMAGE_DEVELOPER_IMAGE=${ROOT%/}/u-boot/u-boot-developer.bin}
: ${CROS_ARM_FIRMWARE_IMAGE_NORMAL_IMAGE=${ROOT%/}/u-boot/u-boot-normal.bin}
: ${CROS_ARM_FIRMWARE_IMAGE_LEGACY_IMAGE=${ROOT%/}/u-boot/u-boot-legacy.bin}

function get_autoconf() {
	# TODO(sjg) grab config from fdt
	grep -m1 $1 ${CROS_ARM_FIRMWARE_IMAGE_AUTOCONF} | tr -d "\"" | cut -d = -f 2
	assert
}

function get_text_base() {
	# Parse the TEXT_BASE value from the U-Boot System.map file.
	grep -m1 -E "^[0-9a-fA-F]{8} T _start$" ${CROS_ARM_FIRMWARE_IMAGE_SYSTEM_MAP} |
		cut -d " " -f 1
	assert
}

function get_screen_geometry() {
	local col=$(get_autoconf CONFIG_LCD_vl_col)
	local row=$(get_autoconf CONFIG_LCD_vl_row)
	echo "${col}x${row}!"
}

function get_chromeos_version() {
	# find and execute the version script:
	# src/third_party/chromiumos-overlay/chromeos/config/chromeos_version.sh

	local version_script="chromeos/config/chromeos_version.sh"
	local overlay
	for overlay in ${PORTDIR_OVERLAY}; do
		if [ -f "${overlay}/${version_script}" ] ; then
			source "${overlay}/${version_script}" > /dev/null
		fi
	done

	if [ -z "${CHROMEOS_VERSION_STRING}" ] ; then
		die "fail to find CHROMEOS_VERSION_STRING"
	fi
	echo "${CHROMEOS_VERSION_STRING}"
}

function construct_layout_helper() {
	echo "FWID_STRING=\"$(get_chromeos_version)\""

	grep -m1 'CONFIG_FIRMWARE_SIZE' ${CROS_ARM_FIRMWARE_IMAGE_AUTOCONF} ||
		die "fail to extract firmware size"

	grep -m1 'CONFIG_CHROMEOS_HWID' ${CROS_ARM_FIRMWARE_IMAGE_AUTOCONF} ||
		die "fail to extract HWID"

	grep -E 'CONFIG_(OFFSET|LENGTH)_\w+' ${CROS_ARM_FIRMWARE_IMAGE_AUTOCONF} ||
		die "fail to extract offsets and lengths"

	cat ${CROS_ARM_FIRMWARE_IMAGE_LAYOUT_CONFIG} ||
		die "fail to cat firmware_layout_config"
}

function construct_layout() {
	construct_layout_helper > ${CROS_ARM_FIRMWARE_IMAGE_LAYOUT}
}

function create_gbb() {
	local hwid=$(get_autoconf CONFIG_CHROMEOS_HWID)
	local gbb_size=$(get_autoconf CONFIG_LENGTH_GBB)
	local bmp_dir="out_${hwid// /_}"
	local make_bmp_image="/usr/share/vboot/bitmaps/make_bmp_images.sh"

	${make_bmp_image} "${hwid}" "$(get_screen_geometry)" "arm"

	pushd "${bmp_dir}"
	bmpblk_utility -z 2 -c ${CROS_ARM_FIRMWARE_IMAGE_SCREEN_CONFIG} bmpblk.bin
	popd

	gbb_utility -c "0x100,0x1000,$((${gbb_size}-0x2180)),0x1000" gbb.bin ||
		die "Failed to create the GBB."

	gbb_utility -s \
		--hwid="${hwid}" \
		--rootkey=${CROS_ARM_FIRMWARE_IMAGE_DEVKEYS}/root_key.vbpubk \
		--recoverykey=${CROS_ARM_FIRMWARE_IMAGE_DEVKEYS}/recovery_key.vbpubk \
		--bmpfv="${bmp_dir}/bmpblk.bin" \
		gbb.bin ||
		die "fail to write keys and hwid to the gbb"
}

function create_image() {
	local prefix=$1
	local stub=${2:-$CROS_ARM_FIRMWARE_IMAGE_STUB_IMAGE}

	# sign the bootstub; this is a combination of the board specific
	# bct and the stub u-boot image.
	cros_sign_bootstub \
		--bct "${CROS_ARM_FIRMWARE_IMAGE_BCT}" \
		--bootstub "${stub}" \
		--output "${prefix}bootstub.bin" \
		--text_base "0x$(get_text_base)" ||
		die "fail to sign boot stub image (${prefix}bootstub.bin)."

	pack_firmware_image ${CROS_ARM_FIRMWARE_IMAGE_LAYOUT} \
		KEYDIR=${CROS_ARM_FIRMWARE_IMAGE_DEVKEYS}/ \
		BOOTSTUB_IMAGE="${prefix}bootstub.bin" \
		RECOVERY_IMAGE=${CROS_ARM_FIRMWARE_IMAGE_RECOVERY_IMAGE} \
		GBB_IMAGE=gbb.bin \
		FIRMWARE_A_IMAGE=${CROS_ARM_FIRMWARE_IMAGE_DEVELOPER_IMAGE} \
		FIRMWARE_B_IMAGE=${CROS_ARM_FIRMWARE_IMAGE_NORMAL_IMAGE} \
		OUTPUT="${prefix}image.bin" ||
		die "fail to pack the firmware image (${prefix}image.bin)."
}

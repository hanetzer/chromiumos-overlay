# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

#
# Original Author: The Chromium OS Authors <chromium-os-dev@chromium.org>
# Purpose: Library for generating ARM firmware image
#

# @ECLASS-VARIABLE: CROS_FIRMWARE_IMAGE_DIR
# @DESCRIPTION
# Directory where the generated files are looked for and placed.
: ${CROS_FIRMWARE_IMAGE_DIR:=${ROOT%/}/u-boot}

# @ECLASS-VARIABLE: CROS_ARM_FIRMWARE_IMAGE_BCT
# @DESCRIPTION
# Location of the board-specific bct file
: ${CROS_FIRMWARE_IMAGE_BCT:=${CROS_FIRMWARE_IMAGE_DIR}/bct/board.bct}

# @ECLASS-VARIABLE: CROS_FIRMWARE_IMAGE_DEVKEYS
# @DESCRIPTION
# Location of the devkeys
: ${CROS_FIRMWARE_IMAGE_DEVKEYS=${ROOT%/}/usr/share/vboot/devkeys}

# @ECLASS-VARIABLE: CROS_FIRMWARE_IMAGE_SYSTEM_MAP
# @DESCRIPTION
# Location of the u-boot symbol table
: ${CROS_FIRMWARE_IMAGE_SYSTEM_MAP=${CROS_FIRMWARE_IMAGE_DIR}/System.map}

# @ECLASS-VARIABLE: CROS_FIRMWARE_IMAGE_AUTOCONF
# @DESCRIPTION
# Location of the u-boot configuration file
: ${CROS_FIRMWARE_IMAGE_AUTOCONF=${CROS_FIRMWARE_IMAGE_DIR}/autoconf.mk}

# @ECLASS-VARIABLE: CROS_FIRMWARE_IMAGE_LAYOUT_CONFIG
# @DESCRIPTION
# Location of the firmware image layout config
: ${CROS_FIRMWARE_IMAGE_LAYOUT_CONFIG=${FILESDIR}/firmware_layout_config}

# @ECLASS-VARIABLE: CROS_FIRMWARE_IMAGE_LAYOUT
# @DESCRIPTION
# Location of the generated layout
: ${CROS_FIRMWARE_IMAGE_LAYOUT=layout.py}

# @ECLASS-VARIABLE: CROS_FIRMWARE_IMAGE_SCREEN_CONFIG
# @DESCRIPTION
# Location of the screen configuration
: ${CROS_FIRMWARE_IMAGE_SCREEN_CONFIG=${FILESDIR}/firmware_screen_config.yaml}

# @ECLASS-VARIABLE: CROS_FIRMWARE_IMAGE_*_IMAGE
# @DESCRIPTION
# Location of the u-boot variants
: ${CROS_FIRMWARE_IMAGE_STUB_IMAGE=${CROS_FIRMWARE_IMAGE_DIR}/u-boot-stub.bin}
: ${CROS_FIRMWARE_IMAGE_RECOVERY_IMAGE=${CROS_FIRMWARE_IMAGE_DIR}/u-boot-recovery.bin}
: ${CROS_FIRMWARE_IMAGE_DEVELOPER_IMAGE=${CROS_FIRMWARE_IMAGE_DIR}/u-boot-developer.bin}
: ${CROS_FIRMWARE_IMAGE_NORMAL_IMAGE=${CROS_FIRMWARE_IMAGE_DIR}/u-boot-normal.bin}
: ${CROS_FIRMWARE_IMAGE_LEGACY_IMAGE=${CROS_FIRMWARE_IMAGE_DIR}/u-boot-legacy.bin}

# @ECLASS-VARIABLE: CROS_FIRMWARE_DTB
# @DESCRIPTION
# Location of the u-boot flat device tree binary blob (FDT)
: ${CROS_FIRMWARE_DTB=}

function get_config() {
	local type=$1
	local key=$2
	dtget -t ${type} ${CROS_FIRMWARE_DTB} ${key}
	assert
}

function get_config_offset() {
	get_config i $1/reg | cut -d' ' -f1
}

function get_config_length() {
	get_config i $1/reg | cut -d' ' -f2
}

function get_text_base() {
	# Parse the TEXT_BASE value from the U-Boot System.map file.
	grep -m1 -E "^[0-9a-fA-F]{8} T _start$" ${CROS_FIRMWARE_IMAGE_SYSTEM_MAP} |
		cut -d " " -f 1
	assert
}

function get_screen_geometry() {
	local col=$(get_config i /lcd/width)
	local row=$(get_config i /lcd/height)
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

	grep -m1 'CONFIG_FIRMWARE_SIZE' ${CROS_FIRMWARE_IMAGE_AUTOCONF} ||
		die "fail to extract firmware size"

	echo "CONFIG_CHROMEOS_HWID=\"$(get_config s /config/hwid)\""

	grep -E 'CONFIG_(OFFSET|LENGTH)_\w+' ${CROS_FIRMWARE_IMAGE_AUTOCONF} ||
		die "fail to extract offsets and lengths"

	cat ${CROS_FIRMWARE_IMAGE_LAYOUT_CONFIG} ||
		die "fail to cat firmware_layout_config"
}

function construct_layout() {
	construct_layout_helper > ${CROS_FIRMWARE_IMAGE_LAYOUT}
}

# XXX Caller must be sure that string does not have '^'; see FIXME below
function dtb_set_config_string() {
	local dtb="$1"
	local property="$2"
	local string="$3"

	#
	# FIXME "%[^^]" (matching anything except '^' character) is a
	# hack of putting a string that:
	#   * contains whitespace character
	#   * but does not contain '^' character (so the choice of '^'
	#     is somewhat arbitrarily)
	# input the dtb file with a '\0' termination.
	#
	# We cannot use "%s", which stops at whitespace, and we cannot
	# use "%${#bootcmd}c", which does not add '\0' to the scanned
	# string. So our only option left is "%[^^]", which does not
	# stop at whitespace and adds '\0' to the end.
	#
	dtput -t s -f "%[^^]" "${dtb}" "/config/${property}" "${string}"
}

function create_gbb() {
	local hwid=$(get_config s /config/hwid)
	local gbb_size=$(get_config_length /flash/gbb)
	local bmp_dir="out_${hwid// /_}"
	local make_bmp_image="/usr/share/vboot/bitmaps/make_bmp_images.sh"

	${make_bmp_image} "${hwid}" "$(get_screen_geometry)" "arm"

	pushd "${bmp_dir}"
	bmpblk_utility -z 2 -c ${CROS_FIRMWARE_IMAGE_SCREEN_CONFIG} bmpblk.bin
	popd

	gbb_utility -c "0x100,0x1000,$((${gbb_size}-0x2180)),0x1000" gbb.bin ||
		die "Failed to create the GBB."

	gbb_utility -s \
		--hwid="${hwid}" \
		--rootkey=${CROS_FIRMWARE_IMAGE_DEVKEYS}/root_key.vbpubk \
		--recoverykey=${CROS_FIRMWARE_IMAGE_DEVKEYS}/recovery_key.vbpubk \
		--bmpfv="${bmp_dir}/bmpblk.bin" \
		gbb.bin ||
		die "fail to write keys and hwid to the gbb"
}

function create_image() {
	local prefix=$1
	local stub=${2:-$CROS_FIRMWARE_IMAGE_STUB_IMAGE}

	if [ -n "${CROS_FIRMWARE_DTB}" ]; then
		# Append the device tree to U-Boot
		elog "FDT: $(ftdump "${CROS_FIRMWARE_DTB}" | grep model)"

		TMPFILE="u-boot.bin.dtb"
		cat "${stub}" "${CROS_FIRMWARE_DTB}" >${TMPFILE} ||
			die "fail to find fdt binary ${CROS_FIRMWARE_DTB}"
		stub="${TMPFILE}"
	fi

	if use arm; then
		# sign the bootstub; this is a combination of the board specific
		# bct and the stub u-boot image.
		cros_sign_bootstub \
		  --bct "${CROS_FIRMWARE_IMAGE_BCT}" \
		  --bootstub "${stub}" \
		  --output "${prefix}bootstub.bin" \
		  --text_base "0x$(get_text_base)" ||
		die "failed to sign boot stub image (${prefix}bootstub.bin)."
	fi
	pack_firmware_image ${CROS_FIRMWARE_IMAGE_LAYOUT} \
		KEYDIR=${CROS_FIRMWARE_IMAGE_DEVKEYS}/ \
		BOOTSTUB_IMAGE="${prefix}bootstub.bin" \
		RECOVERY_IMAGE=${CROS_FIRMWARE_IMAGE_RECOVERY_IMAGE} \
		GBB_IMAGE=gbb.bin \
		FIRMWARE_A_IMAGE=${CROS_FIRMWARE_IMAGE_DEVELOPER_IMAGE} \
		FIRMWARE_B_IMAGE=${CROS_FIRMWARE_IMAGE_NORMAL_IMAGE} \
		OUTPUT="${prefix}image.bin" ||
		die "fail to pack the firmware image (${prefix}image.bin)."
}

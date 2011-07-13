# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit cros-firmware-image

DESCRIPTION="ChromeOS arm firmware image builder"
HOMEPAGE="http://www.chromium.org"
LICENSE=""
SLOT="0"
KEYWORDS="arm x86"
IUSE=""

DEPEND="
	arm? (
			!sys-boot/chromeos-bios
			virtual/tegra-bct
			virtual/u-boot
	     )
	x86? ( sys-boot/chromeos-coreboot )
	chromeos-base/vboot_reference
	"

RDEPEND="${DEPEND}
	sys-apps/flashrom"

if use x86; then
	DST_DIR='/coreboot'
	CROS_FIRMWARE_IMAGE_DIR="${ROOT}${DST_DIR}"
	CROS_FIRMWARE_IMAGE_AUTOCONF="${CROS_FIRMWARE_IMAGE_DIR}/bootconf.mk"
	CROS_FIRMWARE_IMAGE_LAYOUT_CONFIG="${FILESDIR}/"
	CROS_FIRMWARE_IMAGE_LAYOUT_CONFIG+="cb_firmware_layout_config"
	CROS_FIRMWARE_DTB=''
else
	DST_DIR='/u-boot'
	CROS_FIRMWARE_DTB="u-boot.dtb"
fi

# We only have a single U-Boot, and it is called u-boot.bin
# TODO(sjg): simplify the eclass when we deprecate the old U-Boot
CROS_FIRMWARE_IMAGE_STUB_IMAGE="${ROOT%/}/u-boot/u-boot.bin"

ORIGINAL_DTB="${CROS_FIRMWARE_IMAGE_DIR}/u-boot.dtb"

# add extra "echo" concatenates every line into single line
LEGACY_BOOTCMD="$(echo $(cat <<-'EOF'
	usb start;
	if test ${ethact} != ""; then
		run dhcp_boot;
	fi;
	run usb_boot;
	setenv mmcdev 1;
	run mmc_boot;
	setenv mmcdev 0;
	run mmc_boot;
EOF
))"

construct_layout() {
	local layout
	local section
	local nodepath
	for section in $@; do
		nodepath=${section//_/-}
		nodepath=${nodepath,,}
		layout="${layout} ${section}_OFFSET=$(get_config_offset /flash/${nodepath})"
		layout="${layout} ${section}_LENGTH=$(get_config_length /flash/${nodepath})"
	done
	echo ${layout}
}

construct_onestop_blob() {
	local layout
	layout="$(construct_layout FIRMWARE_IMAGE VERIFICATION_BLOCK FIRMWARE_ID)"
	pack_firmware_image "${FILESDIR}/onestop_layout_config" \
		${layout} \
		SIZE=$(get_config_length /flash/onestop-layout) \
		FWID_STRING="'$(get_chromeos_version)'" \
		KEYDIR=${CROS_FIRMWARE_IMAGE_DEVKEYS}/ \
		KEYBLOCK=$2 \
		SIGNPRIVATE=$3 \
		U_BOOT_IMAGE=$1 \
		OUTPUT=$4 || \
	die "fail to pack the $4"
}

pack_image() {
	local layout
	layout="$(construct_layout BCT GBB FMAP RO_ONESTOP RW_A_ONESTOP RW_B_ONESTOP)"
	pack_firmware_image "${FILESDIR}/twostop_layout_config" \
		${layout} \
		SIZE=$(get_config_length /flash) \
		BCT_IMAGE=$1 \
		GBB_IMAGE=$2 \
		RO_ONESTOP_IMAGE=$3 \
		RW_A_ONESTOP_IMAGE=$4 \
		RW_B_ONESTOP_IMAGE=$5 \
		OUTPUT=$6 || \
	die "fail to pack the $6"
}

src_compile() {
	if [ -n "${CROS_FIRMWARE_DTB}" ]; then
		# we are going to modify dtb, and so make a copy first
		cp "${ORIGINAL_DTB}" "${CROS_FIRMWARE_DTB}"
		dtb_set_config_string "${CROS_FIRMWARE_DTB}" bootcmd \
			"run regen_all; vboot_twostop"
	fi

	# TODO(clchiou) fix x86 build later
	if use x86; then
		touch image.bin
		return
	fi

	create_gbb

	# TODO: These codes will be replaced by cros_bundle_firmware

	cat "${CROS_FIRMWARE_IMAGE_STUB_IMAGE}" "${CROS_FIRMWARE_DTB}" > \
		u-boot.dtb.bin
	cros_sign_bootstub \
		--bct "${CROS_FIRMWARE_IMAGE_BCT}" \
		--bootstub u-boot.dtb.bin \
		--output signed_u-boot.dtb.bin \
		--text_base "0x$(get_text_base)" ||
	die "failed to sign image."

	# XXX u-boot.bin (tail of signed u-boot.dtb.bin) is bigger than
	# u-boot.dtb.bin. Is the signed image is padded?
	dd if=signed_u-boot.dtb.bin of=bct.bin bs=512 count=128
	dd if=signed_u-boot.dtb.bin of=u-boot.bin bs=512 skip=128

	construct_onestop_blob u-boot.bin \
		"${CROS_FIRMWARE_IMAGE_DEVKEYS}/dev_firmware.keyblock" \
		"${CROS_FIRMWARE_IMAGE_DEVKEYS}/dev_firmware_data_key.vbprivk" \
		dev_onestop.bin

	construct_onestop_blob u-boot.bin \
		"${CROS_FIRMWARE_IMAGE_DEVKEYS}/firmware.keyblock" \
		"${CROS_FIRMWARE_IMAGE_DEVKEYS}/firmware_data_key.vbprivk" \
		normal_onestop.bin

	pack_image bct.bin \
		gbb.bin \
		normal_onestop.bin \
		normal_onestop.bin \
		dev_onestop.bin \
		image.bin

	# make legacy image
	if use arm && [ -n "${CROS_FIRMWARE_DTB}" ]; then
		cp "${ORIGINAL_DTB}" u-boot-legacy.dtb
		dtb_set_config_string u-boot-legacy.dtb bootcmd "${LEGACY_BOOTCMD}"
		cat "${CROS_FIRMWARE_IMAGE_STUB_IMAGE}" u-boot-legacy.dtb > \
			u-boot-legacy.bin
		cros_sign_bootstub \
			--bct "${CROS_FIRMWARE_IMAGE_BCT}" \
			--bootstub u-boot-legacy.bin \
			--output legacy_image.bin \
			--text_base "0x$(get_text_base)" ||
		die "failed to sign legacy image."
	fi
}

src_install() {
	insinto "${DST_DIR}"
	doins image.bin || die
	if use arm && [ -n "${CROS_FIRMWARE_DTB}" ]; then
		doins legacy_image.bin || die
	fi
}

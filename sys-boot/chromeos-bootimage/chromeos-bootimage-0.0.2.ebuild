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

# TODO(sjg): remove sys-boot/tegra2-fdt in favor of virtual/chromeos-fdt
# whem it is ready
DEPEND="
	arm? (
			!sys-boot/chromeos-bios
			virtual/tegra-bct
			virtual/u-boot
			sys-boot/tegra2-fdt
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
	layout="$(construct_layout RO_FIRMWARE_IMAGE RO_FIRMWARE_ID GBB FMAP RW_A_ONESTOP RW_B_ONESTOP)"
	pack_firmware_image "${FILESDIR}/twostop_layout_config" \
		${layout} \
		SIZE=$(get_config_length /flash) \
		RO_FIRMWARE_IMAGE=$1 \
		GBB_IMAGE=$2 \
		RW_A_ONESTOP_IMAGE=$3 \
		RW_B_ONESTOP_IMAGE=$4 \
		FWID_STRING="'$(get_chromeos_version)'" \
		OUTPUT=$5 || \
	die "fail to pack the $5"
}

src_compile() {
	# TODO(clchiou) fix x86 build later
	if use x86; then
		touch image.bin
		return
	fi

	cros_bundle_firmware \
		--bct "${CROS_FIRMWARE_IMAGE_BCT}" \
		--uboot "${CROS_FIRMWARE_IMAGE_STUB_IMAGE}" \
		--dt "${ORIGINAL_DTB}" \
		--key "${CROS_FIRMWARE_IMAGE_DEVKEYS}" \
		--bootcmd "run regen_all; vboot_twostop" \
		--outdir normal \
		--output image.bin ||
	die "failed to build image."

	# make legacy image
	if use arm && [ -n "${CROS_FIRMWARE_DTB}" ]; then
		cros_bundle_firmware \
			--bct "${CROS_FIRMWARE_IMAGE_BCT}" \
                        --uboot "${CROS_FIRMWARE_IMAGE_STUB_IMAGE}" \
			--dt "${ORIGINAL_DTB}" \
			--key "${CROS_FIRMWARE_IMAGE_DEVKEYS}" \
			--bootcmd "${LEGACY_BOOTCMD}" \
			--add-config-int load_env 1 \
			--outdir legacy \
			--output legacy_image.bin ||
		die "failed to build legacy image."
	fi
}

src_install() {
	insinto "${DST_DIR}"
	doins image.bin || die
	if use arm && [ -n "${CROS_FIRMWARE_DTB}" ]; then
		doins legacy_image.bin || die
	fi
}

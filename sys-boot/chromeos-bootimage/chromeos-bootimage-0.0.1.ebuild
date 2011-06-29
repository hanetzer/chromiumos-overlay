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

# TODO(clchiou): pack and install legacy_image.bin when chromeos-u-boot-next
# generates a legacy u-boot image.

# TODO(clchiou): this is specifically depended on u-boot-next for now, which
# implements onestop firmware; this will depend on virtual/u-boot in the future
DEPEND="arm? ( virtual/tegra-bct
	sys-boot/chromeos-u-boot-next )
	x86? ( sys-boot/chromeos-coreboot )
	chromeos-base/vboot_reference"

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

CROS_FIRMWARE_IMAGE_RECOVERY_IMAGE=zero.bin
CROS_FIRMWARE_IMAGE_DEVELOPER_IMAGE=zero.bin
CROS_FIRMWARE_IMAGE_NORMAL_IMAGE=zero.bin

ORIGINAL_DTB="${CROS_FIRMWARE_IMAGE_DIR}/u-boot.dtb"

# add extra "echo" concatenates every line into single line
LEGACY_BOOTCMD="$(echo $(cat <<-'EOF'
	usb start;
	if test ${ethact} != ""; then
		run dhcp_boot;
	fi;
	run usb_boot;
	run mmc_boot;
EOF
))"


src_compile() {
	if [ -n "${CROS_FIRMWARE_DTB}" ]; then
		# we are going to modify dtb, and so make a copy first
		cp "${ORIGINAL_DTB}" "${CROS_FIRMWARE_DTB}"
		dtb_set_config_string "${CROS_FIRMWARE_DTB}" bootcmd \
			"run regen_all; cros_onestop_firmware"
	fi

	dd if=/dev/zero of=zero.bin count=1
	construct_layout
	create_gbb
	create_image

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

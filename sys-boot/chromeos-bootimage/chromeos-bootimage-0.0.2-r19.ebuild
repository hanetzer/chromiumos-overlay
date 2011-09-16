# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

inherit cros-debug

DESCRIPTION="ChromeOS firmware image builder"
HOMEPAGE="http://www.chromium.org"
LICENSE=""
SLOT="0"
KEYWORDS="arm x86"
BOARDS="alex stumpy lumpy mario"
IUSE="${BOARDS}"

REQUIRED_USE="^^ ( ${BOARDS} arm )"

# TODO(dianders) Eventually we'll have virtual/chromeos-bootimage.
# When that happens the various implementations (like
# sys-boot/chromeos-bootimage-seaboard) will do the depending on
# sys-boot/tegra2-public-firmware-fdts.  For now we'll hardcode it.
DEPEND="
	arm? ( virtual/tegra-bct )
	x86? ( sys-boot/chromeos-coreboot )
	x86? ( sys-apps/coreboot-utils )
	virtual/u-boot
	chromeos-base/vboot_reference
	"

# TODO(clchiou): Here are the action items for fixing x86 build that I can
# think of:
# * Make BCT optional to cros_bundle_firmware because it is specific to ARM

S=${WORKDIR}

# The real bmpblk must be verified and installed by HWID matchin in
# factory process. Default one should be a pre-genereated blob.
BMPBLK_FILE="${FILESDIR}/default.bmpblk"

src_compile() {

	local secure_flags=''
	local common_flags=''
	local bct_file
	local fdt_file
	local image_file
	local devkeys_file

	# Directory where the generated files are looked for and placed.
	CROS_FIRMWARE_IMAGE_DIR="/firmware"
	CROS_FIRMWARE_ROOT="${ROOT%/}${CROS_FIRMWARE_IMAGE_DIR}/"

	# Location of the board-specific bct file
	bct_file="${ROOT%/}${CROS_FIRMWARE_IMAGE_DIR}/bct/board.bct"

	# Location of the u-boot flat device tree binary blob (FDT)
	# TODO(dianders): remove looking at PKG_CONFIG once
	# virtual/chromeos-bootimage is complete.
	fdt_file="$(echo "${PKG_CONFIG#pkg-config-}.dtb" | tr _ '-')"
	fdt_file="${CROS_FIRMWARE_ROOT}/dtb/${fdt_file#x86-}"

	# We only have a single U-Boot, and it is called u-boot.bin
	image_file="${CROS_FIRMWARE_ROOT}/u-boot.bin"

	# Location of the devkeys
	devkeys_file="${ROOT%/}/usr/share/vboot/devkeys"

	if ! use cros-debug; then
		secure_flags+=' --add-config-int silent_console 1'
	fi
	if use x86; then
		common_flags+=" --coreboot \
			${CROS_FIRMWARE_ROOT}/coreboot.rom"
	fi

	cros_bundle_firmware \
		${common_flags} \
		--bct "${bct_file}" \
		--uboot "${image_file}" \
		--dt "${fdt_file}" \
		--key "${devkeys_file}" \
		--bmpblk "${BMPBLK_FILE}" \
		--bootcmd "vboot_twostop" \
		--bootsecure \
		${secure_flags} \
		--outdir normal \
		--output image.bin ||
	die "failed to build image."

	# make legacy image
	cros_bundle_firmware \
		${common_flags} \
		--bct "${bct_file}" \
		--uboot "${image_file}" \
		--dt "${fdt_file}" \
		--key "${devkeys_file}" \
		--bmpblk "${BMPBLK_FILE}" \
		--add-config-int load_env 1 \
		--outdir legacy \
		--output legacy_image.bin ||
	die "failed to build legacy image."

	if use x86; then
		local skeleton="${CROS_FIRMWARE_ROOT}/skeleton.bin"
		local ifdtool="/usr/bin/ifdtool"
		if [ -r ${skeleton} ]; then
			cp ${skeleton} image.ifd
			${ifdtool} -i BIOS:image.bin image.ifd
			cp ${skeleton} legacy_image.ifd
			${ifdtool} -i BIOS:legacy_image.bin legacy_image.ifd
		fi
	fi
}

src_install() {
	insinto "${CROS_FIRMWARE_IMAGE_DIR}"
	doins image.bin
	doins legacy_image.bin
	doins ${BMPBLK_FILE}
	if use x86; then
		local skeleton="${CROS_FIRMWARE_ROOT}/skeleton.bin"
		if [ -r ${skeleton} ]; then
			newins image.ifd.new image.ifd
			newins legacy_image.ifd.new legacy_image.ifd
		fi
	fi
	# -----------------------------------------------------------------
	# The following section is going away as soon as all scripts and
	# ebuilds have been migrated to use the new /firmware location
	# -----------------------------------------------------------------
	if use x86; then
		CROS_FIRMWARE_IMAGE_DIR="/coreboot"
	else
		CROS_FIRMWARE_IMAGE_DIR="/u-boot"
	fi
	insinto "${CROS_FIRMWARE_IMAGE_DIR}"
	doins image.bin
	doins legacy_image.bin
	doins ${BMPBLK_FILE}
	if use x86; then
		local skeleton="${CROS_FIRMWARE_ROOT}/skeleton.bin"
		if [ -r ${skeleton} ]; then
			newins image.ifd.new image.ifd
			newins legacy_image.ifd.new legacy_image.ifd
		fi
	fi
	# -----------------------------------------------------------------
}

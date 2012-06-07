# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

inherit cros-debug

DESCRIPTION="ChromeOS firmware image builder"
HOMEPAGE="http://www.chromium.org"
LICENSE=""
SLOT="0"
KEYWORDS="amd64 arm x86"
BOARDS="alex emeraldlake2 link lumpy lumpy64 mario parrot stumpy"
IUSE="${BOARDS} exynos factory-mode memtest seabios tegra"

REQUIRED_USE="^^ ( ${BOARDS} arm )"

X86_DEPEND="
	       sys-boot/chromeos-coreboot
	       sys-apps/coreboot-utils

"
# TODO(dianders) Eventually we'll have virtual/chromeos-bootimage.
# When that happens the various implementations (like
# sys-boot/chromeos-bootimage-seaboard) will do the depending on
# sys-boot/tegra2-public-firmware-fdts.  For now we'll hardcode it.
DEPEND="
	exynos? ( sys-boot/exynos-pre-boot )
	tegra? ( virtual/tegra-bct )
	x86? ( ${X86_DEPEND} )
	amd64? ( ${X86_DEPEND} )
	virtual/u-boot
	chromeos-base/vboot_reference
	seabios? ( sys-boot/chromeos-seabios )
	memtest? ( sys-boot/chromeos-memtest )
	"

# TODO(clchiou): Here are the action items for fixing x86 build that I can
# think of:
# * Make BCT optional to cros_bundle_firmware because it is specific to ARM

S=${WORKDIR}

# The real bmpblk must be verified and installed by HWID matchin in
# factory process. Default one should be a pre-genereated blob.
BMPBLK_FILE="${FILESDIR}/default.bmpblk"

netboot_required() {
	! use memtest && ( use factory-mode || use link )
}

# Build vboot and non-vboot images for the given device tree file
# A vboot image performs a full verified boot, and this is the normal case.
# A non-vboot image doesn't do a check for updated firmware, and just boots
# the kernel without verity enabled.
# Args:
#    $1: fdt_file - full name of device tree file
#    $2: uboot_file - full name of U-Boot binary
#    $3: common_flags - flags to use for all images
#    $4: verified_flags - extra flags to use for verified image
#    $5: nv_flags - extra flags to pass for non-verified image
build_image() {
	local nv_uboot_file
	local fdt_file="$1"
	local uboot_file="$2"
	local common_flags="$3"
	local verified_flags="$4"
	local nv_flags="$5"

	einfo "Building images for ${fdt_file}"
	cros_bundle_firmware \
		${common_flags} \
		--dt ${fdt_file} \
		--uboot ${uboot_file} \
		--bootcmd "vboot_twostop" \
		--bootsecure \
		${verified_flags} \
		--outdir out \
		--output image.bin ||
		die "failed to build image."

	# Make non-vboot image
	nv_uboot_file="${uboot_file}"
	if netboot_required; then
		nv_uboot_file="${CROS_FIRMWARE_ROOT}/u-boot_netboot.bin"
	fi
	cros_bundle_firmware \
		${common_flags} \
		--dt ${fdt_file} \
		--uboot ${nv_uboot_file} \
		--add-config-int load_env 1 \
		--add-node-enable console 1 \
		${nv_flags} \
		--outdir nvout \
		--output nv_image.bin ||
		die "failed to build legacy image."
}

src_compile() {

	local secure_flags=''
	local common_flags=''
	local seabios_flags=''
	local bct_file
	local fdt_file
	local uboot_file
	local devkeys_file
	local dd_params

	# Directory where the generated files are looked for and placed.
	CROS_FIRMWARE_IMAGE_DIR="/firmware"
	CROS_FIRMWARE_ROOT="${ROOT%/}${CROS_FIRMWARE_IMAGE_DIR}"

	# Location of the board-specific bct file
	bct_file="${ROOT%/}${CROS_FIRMWARE_IMAGE_DIR}/bct/board.bct"

	# Location of the U-Boot flat device tree source file
	fdt_file="${CROS_FIRMWARE_ROOT}/dts/${U_BOOT_FDT_USE}.dts"

	if use memtest; then
		uboot_file="${CROS_FIRMWARE_ROOT}/x86-memtest"
	else
		# We only have a single U-Boot, and it is called u-boot.bin
		uboot_file="${CROS_FIRMWARE_ROOT}/u-boot.bin"
	fi

	# Location of the devkeys
	devkeys_file="${ROOT%/}/usr/share/vboot/devkeys"

	# Add a SeaBIOS payload
	if use seabios; then
		seabios_flags+=" --seabios=${CROS_FIRMWARE_ROOT}/bios.bin.elf"
	fi

	if ! use x86 && ! use amd64 && ! use cros-debug; then
		secure_flags+=' --add-config-int silent_console 1'
	fi
	if use x86 || use amd64; then
		common_flags+=" --coreboot \
			${CROS_FIRMWARE_ROOT}/coreboot.rom"
	fi

	common_flags+=" --board ${BOARD_USE} --bct ${bct_file}"
	common_flags+=" --key ${devkeys_file} --bmpblk ${BMPBLK_FILE}"

	build_image "${fdt_file}" "${uboot_file}" "${common_flags}" \
			"${verified_flags}" "${seabios_flags}"
}

src_install() {
	insinto "${CROS_FIRMWARE_IMAGE_DIR}"
	doins *image*.bin
	doins ${BMPBLK_FILE}
}

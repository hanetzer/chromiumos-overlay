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

src_compile() {

	local secure_flags=''
	local common_flags=''
	local seabios_flags=''
	local bct_file
	local fdt_file
	local image_file
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
		image_file="${CROS_FIRMWARE_ROOT}/x86-memtest"
	else
		# We only have a single U-Boot, and it is called u-boot.bin
		image_file="${CROS_FIRMWARE_ROOT}/u-boot.bin"
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

	cros_bundle_firmware \
		${common_flags} \
		--dt ${fdt_file} \
		--uboot ${image_file} \
		--bootcmd "vboot_twostop" \
		--bootsecure \
		${secure_flags} \
		--outdir normal \
		--output image.bin ||
	die "failed to build image."

	if netboot_required; then
		image_file="${CROS_FIRMWARE_ROOT}/u-boot_netboot.bin"
	fi
	# Make legacy image, with console always enabled
	cros_bundle_firmware \
		${common_flags} \
		--dt ${fdt_file} \
		--uboot ${image_file} \
		--add-config-int load_env 1 \
		--add-node-enable console 1 \
		${seabios_flags} \
		--outdir legacy \
		--output legacy_image.bin ||
	die "failed to build legacy image."

	if use x86 || use amd64; then
		if use link || use emeraldlake2 || use parrot; then
			dd_params='bs=2M skip=1'
		else
			dd_params='bs=512K skip=3'
		fi
		local skeleton="${CROS_FIRMWARE_ROOT}/skeleton.bin"
		local ifdtool="/usr/bin/ifdtool"
		if [ -r ${skeleton} ]; then
			# cros_bundle_firmware only produces the system firmware.
			# In order to produce a working image on Sandybridge we
			# need to embed this image into a Firmware Descriptor image
			# that contains ME firmware and possibly some other BLOBs.
			dd if=image.bin of=image_sys.bin ${dd_params} || die
			dd if=legacy_image.bin of=legacy_image_sys.bin \
				 ${dd_params} || die
			cp ${skeleton} image.ifd || die
			${ifdtool} -i BIOS:image_sys.bin image.ifd || die
			cp ${skeleton} legacy_image.ifd || die
			${ifdtool} -i BIOS:legacy_image_sys.bin \
				legacy_image.ifd || die
			# Rename the final image.ifd to image.bin, so we don't
			# have to add a lot of handling for two different names
			# in other places. But we also want to keep the original
			# cros_bundle_firmware images around (as image_sys.bin)
			mv image.ifd.new image.bin || die
			mv legacy_image.ifd.new legacy_image.bin || die
		fi
	fi
}

src_install() {
	insinto "${CROS_FIRMWARE_IMAGE_DIR}"
	doins image.bin
	doins legacy_image.bin
	doins ${BMPBLK_FILE}
	if use x86 || use amd64; then
		local skeleton="${CROS_FIRMWARE_ROOT}/skeleton.bin"
		if [ -r ${skeleton} ]; then
			doins image_sys.bin
			doins legacy_image_sys.bin
		fi
	fi
}

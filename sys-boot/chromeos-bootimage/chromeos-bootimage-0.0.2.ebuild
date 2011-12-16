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
IUSE="${BOARDS} seabios"

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
	seabios? ( sys-boot/chromeos-seabios )
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
	local seabios_flags=''
	local bct_file
	local fdt_file
	local image_file
	local devkeys_file
	local dd_params

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

	# Add a SeaBIOS payload
	if use seabios; then
		seabios_flags+=" --seabios=${CROS_FIRMWARE_ROOT}/bios.bin.elf"
	fi

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
		${seabios_flags} \
		--outdir legacy \
		--output legacy_image.bin ||
	die "failed to build legacy image."

	if use x86; then
		if use link; then
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
	if use x86; then
		local skeleton="${CROS_FIRMWARE_ROOT}/skeleton.bin"
		if [ -r ${skeleton} ]; then
			doins image_sys.bin
			doins legacy_image_sys.bin
		fi
	fi
}

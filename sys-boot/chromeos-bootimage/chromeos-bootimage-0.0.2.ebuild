# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

inherit cros-debug

DESCRIPTION="ChromeOS firmware image builder"
HOMEPAGE="http://www.chromium.org"
LICENSE=""
SLOT="0"
KEYWORDS="amd64 arm x86"
# TODO(sjg@chromium.org): Remove when x86 can build all boards
BOARDS="alex butterfly emeraldlake2 fox link lumpy lumpy64 mario parrot stout stumpy"
IUSE="${BOARDS} exynos factory-mode memtest tegra cros_ec depthcharge unified_depthcharge spring"

REQUIRED_USE="^^ ( ${BOARDS} arm )"

X86_DEPEND="
	       virtual/chromeos-coreboot
	       sys-apps/coreboot-utils
	       sys-boot/chromeos-seabios
"
DEPEND="
	exynos? ( sys-boot/exynos-pre-boot )
	tegra? ( virtual/tegra-bct )
	x86? ( ${X86_DEPEND} )
	amd64? ( ${X86_DEPEND} )
	virtual/u-boot
	cros_ec? ( chromeos-base/chromeos-ec )
	chromeos-base/vboot_reference
	sys-boot/chromeos-bmpblk
	memtest? ( sys-boot/chromeos-memtest )
	depthcharge? ( sys-boot/depthcharge )
	"

S=${WORKDIR}

# Directory where the generated files are looked for and placed.
CROS_FIRMWARE_IMAGE_DIR="/firmware"
CROS_FIRMWARE_ROOT="${ROOT%/}${CROS_FIRMWARE_IMAGE_DIR}"

netboot_required() {
	! use memtest && ( use factory-mode || use link || use spring)
}

# Build vboot and non-vboot images for the given device tree file
# A vboot image performs a full verified boot, and this is the normal case.
# A non-vboot image doesn't do a check for updated firmware, and just boots
# the kernel without verity enabled.
# Args:
#    $1: fdt_file - full name of device tree file
#    $2: uboot_file - full name of U-Boot binary
#    $3: ec_file - full name of the EC read/write binary
#    $4: common_flags - flags to use for all images
#    $5: verified_flags - extra flags to use for verified image
#    $6: nv_flags - extra flags to pass for non-verified image

build_image() {
	local nv_uboot_file
	local fdt_file="$1"
	local uboot_file="$2"
	local ec_file="$3"
	local common_flags="$4"
	local verified_flags="$5"
	local nv_flags="$6"

	local board
	local base

	local ec_file_flag
	if use cros_ec; then
		ec_file_flag="--ec ${ec_file}"
	else
		ec_file_flag=""
	fi
	einfo "Building images for ${fdt_file}"

	# Bash stuff to turn '/path/to/exynos-5250-snow.dts' into 'snow'
	base=$(basename ${fdt_file})
	board=${base%%.dts}
	board=${board##*-}

	# TODO(vbendeb): remove this once peach is better supported:
	# Exynos5420 boards should not be using default component locations.
	local soc=${base/-*}  # Get soc name out of the device tree name.
	if [[ "${soc}" == "exynos5420" ]]; then
		common_flags+=' --bl1=/build/peach/firmware/E5420.nbl1.bin'
		common_flags+=' --bl2=/build/peach/firmware/smdk5420-spl.bin'
		common_flags+=' -D -s'
	fi

	cmdline="${common_flags} \
		--dt ${fdt_file} \
		--uboot ${uboot_file} \
		${ec_file_flag} \
		--bootcmd vboot_twostop \
		--bootsecure \
		${verified_flags}"

	# Build an RO-normal image, and an RW (twostop) image. This assumes
	# that the fdt has the flags set to 1 by default.
	cros_bundle_firmware ${cmdline} \
		--outdir "out-${board}.ro" \
		--output "image-${board}.bin" ||
		die "failed to build image."
	cros_bundle_firmware ${cmdline} --force-rw \
		--outdir "out-${board}.rw" \
		--output "image-${board}.rw.bin" ||
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
		${ec_file_flag} \
		--add-config-int load_env 1 \
		--add-node-enable console 1 \
		${nv_flags} \
		--outdir "nvout-${board}" \
		--output "nv_image-${board}.bin" ||
		die "failed to build legacy image."
}

src_compile_uboot() {

	local verified_flags=''
	local common_flags=''
	local bct_file
	local fdt_file
	local uboot_file
	local devkeys_file
	local dd_params

	# Location of the board-specific bct file
	bct_file="${ROOT%/}${CROS_FIRMWARE_IMAGE_DIR}/bct/board.bct"

	if use memtest; then
		uboot_file="${CROS_FIRMWARE_ROOT}/x86-memtest"
	else
		# We only have a single U-Boot, and it is called u-boot.bin
		uboot_file="${CROS_FIRMWARE_ROOT}/u-boot.bin"
	fi

	# Location of the EC RW image
	ec_file="${CROS_FIRMWARE_ROOT}/ec.RW.bin"

	# Location of the devkeys
	devkeys_file="${ROOT%/}/usr/share/vboot/devkeys"

	if ! use x86 && ! use amd64 && ! use cros-debug; then
		verified_flags+=' --add-config-int silent_console 1'
	fi
	if use x86 || use amd64; then
		# Add a SeaBIOS payload
		common_flags+=" --seabios ${CROS_FIRMWARE_ROOT}/seabios.cbfs"
		common_flags+=" --coreboot \
			${CROS_FIRMWARE_ROOT}/coreboot.rom"
	fi

	# TODO(clchiou): The cros_splash_blob is a short-term hack; remove this
	# when we have vboot-next.  See chrome-os-partner:17716 for details.
	if use exynos; then
		common_flags+=" --add-blob cros-splash"
		common_flags+=" ${FILESDIR}/cros_splash_blob.bin"
	fi

	common_flags+=" --board ${BOARD_USE} --bct ${bct_file}"
	common_flags+=" --key ${devkeys_file}"
	common_flags+=" --bmpblk ${CROS_FIRMWARE_ROOT}/bmpblk.bin"

	# TODO(sjg@chromium.org): For x86 we can't build all the images
	# yet, since we need to use a different skeleton file for each.

	if use x86 || use amd64; then
		einfo "x86: Only building for board ${U_BOOT_FDT_USE}"
		# Location of the U-Boot flat device tree source file
		fdt_file="${CROS_FIRMWARE_ROOT}/dts/${U_BOOT_FDT_USE}.dts"
		build_image "${fdt_file}" "${uboot_file}" "${ec_file}" \
				"${common_flags}" "${verified_flags}" ""

	else
		einfo "Building all images"
		for fdt_file in ${CROS_FIRMWARE_ROOT}/dts/*.dts; do
			build_image "${fdt_file}" "${uboot_file}" \
				"${ec_file}" "${common_flags}" \
				"${verified_flags}" ""
		done
	fi
}

src_compile_depthcharge() {
	local froot="${CROS_FIRMWARE_ROOT}"
	# Location of various files
	local bct_file="${ROOT%/}${CROS_FIRMWARE_IMAGE_DIR}/bct/board.bct"
	local ec_file="${froot}/ec.RW.bin"
	local devkeys_file="${ROOT%/}/usr/share/vboot/devkeys"
	local fdt_file="${froot}/dts/fmap.dts"
	local bmpblk_file="${froot}/bmpblk.bin"
	local coreboot_file="${froot}/coreboot.rom"
	local ramstage_file="${froot}/coreboot_ram.stage"

	local uboot_file
	if use unified_depthcharge; then
		uboot_file="${froot}/depthcharge/depthcharge.unified.payload"
		if [[ ! -a "${uboot_file}" ]]; then
			uboot_file="${froot}/depthcharge/depthcharge.payload"
		fi
	else
		uboot_file="${froot}/depthcharge/depthcharge.rw.bin"
	fi

	local common=(
		--board "${BOARD_USE}"
		--bct "${bct_file}"
		--key "${devkeys_file}"
		--bmpblk "${bmpblk_file}"
		--coreboot "${coreboot_file}"
		--dt "${fdt_file}"
		--uboot "${uboot_file}"
	)

	if use x86 || use amd64; then
		common+=(
			--seabios "${CROS_FIRMWARE_ROOT}/seabios.cbfs"
			--add-blob ramstage "${ramstage_file}"
		)
	fi

	if use cros_ec; then
		common+=( --ec "${ec_file}" )
	fi

	local depthcharge_elf
	if use unified_depthcharge; then
		depthcharge_elf="${froot}/depthcharge/depthcharge.unified.elf"
		if [[ ! -a "${depthcharge_elf}" ]]; then
			depthcharge_elf="${froot}/depthcharge/depthcharge.elf"
		fi
	else
		depthcharge_elf="${froot}/depthcharge/depthcharge.ro.elf"
	fi

	local netboot_elf="${froot}/depthcharge/netboot.elf"

	einfo "Building RO image."
	cros_bundle_firmware ${common[@]} \
		--coreboot-elf="${depthcharge_elf}" \
		--outdir "out.ro" --output "image.bin" ||
		die "failed to build RO image."
	einfo "Building RW image."
	cros_bundle_firmware "${common[@]}" --force-rw \
		--coreboot-elf="${depthcharge_elf}" \
		--outdir "out.rw" --output "image.rw.bin" ||
		die "failed to build RW image."

	# Build a netboot image.
	einfo "Building netboot image."
	cros_bundle_firmware "${common[@]}" \
		--coreboot-elf="${netboot_elf}" \
		--outdir "out.net" --output "image.net.bin" ||
		die "failed to build netboot image."
}

src_compile() {
	if use depthcharge; then
		src_compile_depthcharge
	else
		src_compile_uboot
	fi
}

src_install() {
	insinto "${CROS_FIRMWARE_IMAGE_DIR}"
	doins *image*.bin
}

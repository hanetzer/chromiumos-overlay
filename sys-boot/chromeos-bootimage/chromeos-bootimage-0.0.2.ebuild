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
BOARDS="alex butterfly emeraldlake2 link lumpy lumpy64 mario parrot stout stumpy"
IUSE="${BOARDS} exynos factory-mode memtest tegra cros_ec"

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
	"

S=${WORKDIR}

# Directory where the generated files are looked for and placed.
CROS_FIRMWARE_IMAGE_DIR="/firmware"
CROS_FIRMWARE_ROOT="${ROOT%/}${CROS_FIRMWARE_IMAGE_DIR}"

netboot_required() {
	! use memtest && ( use factory-mode || use link )
}

create_seabios_cbfs() {
	local oprom=${CROS_FIRMWARE_ROOT}/pci????,????.rom
	local seabios_cbfs=seabios.cbfs
	local cbfs_size=$(( 2*1024*1024 ))
	local bootblock=$( mktemp )

	# Create a dummy bootblock to make cbfstool happy
	dd if=/dev/zero of=$bootblock count=1 bs=64
	# Create empty CBFS
	cbfstool ${seabios_cbfs} create ${cbfs_size} $bootblock
	# Clean up
	rm $bootblock
	# Add SeaBIOS binary to CBFS
	cbfstool ${seabios_cbfs} add-payload ${CROS_FIRMWARE_ROOT}/bios.bin.elf payload
	# Add VGA option rom to CBFS
	cbfstool ${seabios_cbfs} add $oprom $( basename $oprom ) optionrom
	# Print CBFS inventory
	cbfstool ${seabios_cbfs} print
	# Fix up CBFS to live at 0xffc00000. The last four bytes of a CBFS
	# image are a pointer to the CBFS master header. Per default a CBFS
	# lives at 4G - rom size, and the CBFS master header ends up at
	# 0xffffffa0. However our CBFS lives at 4G-4M and is 2M in size, so
	# the CBFS master header is at 0xffdfffa0 instead. The two lines
	# below correct the according byte in that pointer to make all CBFS
	# parsing code happy. In the long run we should fix cbfstool and
	# remove this workaround.
	/bin/echo -ne \\0737 | dd of=${seabios_cbfs} \
			seek=$(( ${cbfs_size} - 2 )) bs=1 conv=notrunc
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
	cros_bundle_firmware \
		${common_flags} \
		--dt ${fdt_file} \
		--uboot ${uboot_file} \
		${ec_file_flag} \
		--bootcmd "vboot_twostop" \
		--bootsecure \
		${verified_flags} \
		--outdir out \
		--output "image-${board}.bin" ||
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
		--outdir nvout \
		--output "nv_image-${board}.bin" ||
		die "failed to build legacy image."
}

src_compile() {

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
		create_seabios_cbfs
		common_flags+=" --seabios ./seabios.cbfs"
		common_flags+=" --coreboot \
			${CROS_FIRMWARE_ROOT}/coreboot.rom"
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

src_install() {
	insinto "${CROS_FIRMWARE_IMAGE_DIR}"
	doins *image*.bin
}

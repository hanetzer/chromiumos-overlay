# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

# need to check out factory source for update_firmware_settings.py for now
CROS_WORKON_COMMIT="bcf911c727036106df2e491252f0e18634d79ab8"
CROS_WORKON_TREE="c54b9e8c20a2961d16bb4f942eccd5e67400445d"
CROS_WORKON_PROJECT="chromiumos/platform/factory"
CROS_WORKON_LOCALNAME="../platform/factory"

inherit cros-debug cros-workon

DESCRIPTION="ChromeOS firmware image builder"
HOMEPAGE="http://www.chromium.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
# TODO(sjg@chromium.org): Remove when x86 can build all boards
BOARDS="alex bayleybay beltino bolt butterfly emeraldlake2 falco fox gizmo link"
BOARDS="${BOARDS} lumpy lumpy64 mario panther parrot peppy rambi samus slippy"
BOARDS="${BOARDS} squawks stout stumpy"
IUSE="${BOARDS} build-all-fw exynos factory-mode memtest tegra cros_ec efs"
IUSE="${IUSE} depthcharge unified_depthcharge spring"

REQUIRED_USE="^^ ( ${BOARDS} arm )"

COREBOOT_DEPEND="
	sys-apps/coreboot-utils
	sys-boot/coreboot
"
X86_DEPEND="
	${COREBOOT_DEPEND}
	sys-boot/chromeos-seabios
"
DEPEND="
	exynos? ( sys-boot/exynos-pre-boot )
	tegra? ( virtual/tegra-bct )
	x86? ( ${X86_DEPEND} )
	amd64? ( ${X86_DEPEND} )
	!depthcharge? ( virtual/u-boot )
	cros_ec? ( chromeos-base/chromeos-ec )
	chromeos-base/vboot_reference
	sys-boot/chromeos-bmpblk
	memtest? ( sys-boot/chromeos-memtest )
	depthcharge? ( ${COREBOOT_DEPEND} sys-boot/depthcharge )
	"

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
#    $3: common_flags - flags to use for all images
#    $4: verified_flags - extra flags to use for verified image
#    $5: uboot_ro_file - full name of U-Boot RO binary

build_image() {
	local nv_uboot_file
	local fdt_file="$1"
	local uboot_file="$2"
	local common_flags="$3"
	local verified_flags="$4"
	local uboot_ro_file="$5"
	local board base ec_file_flag

	if use cros_ec; then
		common_flags+=" --ecro ${CROS_FIRMWARE_ROOT}/ec.RO.bin"
		common_flags+=" --ec ${CROS_FIRMWARE_ROOT}/ec.RW.bin"
	fi
	einfo "Building images for ${fdt_file}"

	# Bash stuff to turn '/path/to/exynos5250-snow.dtb' into 'snow' and
	# '/path/to/exynos5250-peach-pit.dtb' into 'peach-pit'
	base=${fdt_file##*/}
	board=${base%.dtb}
	board=${board#*-}

	if use exynos; then
		common_flags+=' -D' # Please no default components.
		common_flags+=" --bl1=${CROS_FIRMWARE_ROOT}/u-boot.bl1.bin"
		common_flags+=" --bl2="
		common_flags+="${CROS_FIRMWARE_ROOT}/u-boot-spl.wrapped.bin"
	fi

	cmdline="${common_flags} \
		--dt ${fdt_file} \
		--uboot ${uboot_file} \
		${ec_file_flag} \
		--bootcmd vboot_twostop \
		--bootsecure \
		--add-config-int load-environment 0 \
		${verified_flags}"

	# Build an RO-normal image, and an RW (twostop) image. This assumes
	# that the fdt has the flags set to 1 by default.
	cros_bundle_firmware ${cmdline} \
		--add-blob ro-boot "${uboot_file}" \
		--outdir "out-${board}.ro" \
		--output "image-${board}.bin" ||
		die "failed to build RO image: ${cmdline}"
	cros_bundle_firmware ${cmdline} --force-rw \
		--add-blob ro-boot "${uboot_file}" \
		--outdir "out-${board}.rw" \
		--output "image-${board}.rw.bin" ||
		die "failed to build RW image: ${cmdline}"
	if use efs; then
		cros_bundle_firmware ${cmdline} --force-rw \
			--add-blob ro-boot "${uboot_ro_file}" \
			--force-efs  \
			--outdir "out-${board}.efs" \
			--output "image-${board}.efs.bin" ||
			die "failed to build EFS image: ${cmdline}"
	fi

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
		--add-node-enable console 1 \
		--outdir "out-${board}.nv" \
		--output "nv_image-${board}.bin" ||
		die "failed to build legacy image: ${cmdline}"
}

src_compile_uboot() {

	local verified_flags=''
	local common_flags=''
	local fdt_file
	local uboot_file
	local devkeys_file
	local dd_params
	local uboot_ro_file

	if use memtest; then
		uboot_file="${CROS_FIRMWARE_ROOT}/x86-memtest"
	else
		# We only have a single U-Boot, and it is called u-boot.bin
		uboot_file="${CROS_FIRMWARE_ROOT}/u-boot.bin"
	fi
	uboot_ro_file="${CROS_FIRMWARE_ROOT}/u-boot-ro.bin"

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

	common_flags+=" --board ${BOARD_USE}"
	common_flags+=" --key ${devkeys_file}"
	common_flags+=" --bmpblk ${CROS_FIRMWARE_ROOT}/bmpblk.bin"

	if use tegra; then
		common_flags+=" --bct ${CROS_FIRMWARE_ROOT}/bct/board.bct"
	fi

	# TODO(sjg@chromium.org): For x86 we can't build all the images
	# yet, since we need to use a different skeleton file for each.
	if use arm && use build-all-fw; then
		einfo "Building all images"
		for fdt_file in "${CROS_FIRMWARE_ROOT}"/dtb/*.dtb; do
			build_image "${fdt_file}" "${uboot_file}" \
				"${common_flags}" "${verified_flags}" \
				"${uboot_ro_file}"
		done
	else
		if use build-all-fw; then
			ewarn "Cannot build all images except on ARM"
		fi
		einfo "Building for board ${U_BOOT_FDT_USE}"
		# Location of the U-Boot flat device tree source file
		fdt_file="${CROS_FIRMWARE_ROOT}/dtb/${U_BOOT_FDT_USE}.dtb"
		build_image "${fdt_file}" "${uboot_file}" "${common_flags}" \
			"${verified_flags}" "${uboot_ro_file}"
	fi
}

src_compile_depthcharge() {
	local froot="${CROS_FIRMWARE_ROOT}"
	# Location of various files

	local ec_file="${froot}/ec.RW.bin"
	local devkeys_file="${ROOT%/}/usr/share/vboot/devkeys"
	local fdt_file="${froot}/dts/fmap.dts"
	local bmpblk_file="${froot}/bmpblk.bin"
	local coreboot_file="${froot}/coreboot.rom"
	local ramstage_file="${froot}/ramstage.stage"
	local refcode_file="${froot}/refcode.stage"

	local uboot_file

	if [ "${BOARD_USE}" == "storm" ]; then
		local dest_file="image.bin"

		eerror "Temp bootimage building code, needs to be fixed!!"

		cp "${coreboot_file}" "${dest_file}.tmp" || \
		  die "failed to create ${dest_file}.tmp"
		cbfstool "${dest_file}.tmp"  add-payload \
		  -f "${froot}/depthcharge/depthcharge.elf" \
		  -n "fallback/payload" -c lzma || \
		  die "failed to add to ${dest_file}.tmp"
		mv "${dest_file}.tmp" "${dest_file}" || \
		  die "failed to create ${dest_file}"
		return 0
	fi

	if use unified_depthcharge; then
		uboot_file="${froot}/depthcharge/depthcharge.payload"
	else
		uboot_file="${froot}/depthcharge/depthcharge.rw.bin"
	fi
	local netboot_file
	if use unified_depthcharge; then
		netboot_file="${froot}/depthcharge/netboot.payload"
	else
		netboot_file="${froot}/depthcharge/netboot.bin"
	fi

	local common=(
		--board "${BOARD_USE}"
		--key "${devkeys_file}"
		--bmpblk "${bmpblk_file}"
		--coreboot "${coreboot_file}"
		--dt "${fdt_file}"
	)

	# If unified depthcharge is being used always include ramstage_file.
	if use unified_depthcharge; then
		common+=(
			--add-blob ramstage "${ramstage_file}"
		)
	fi

	if use x86 || use amd64; then
		common+=(
			--seabios "${CROS_FIRMWARE_ROOT}/seabios.cbfs"
		)
		if [ -f "${refcode_file}" ]; then
			common+=(
				--add-blob refcode "${refcode_file}"
			)
		fi
	fi

	if use cros_ec; then
		common+=( --ec "${ec_file}" )
	fi

	local depthcharge_elf
	if use unified_depthcharge; then
		depthcharge_elf="${froot}/depthcharge/depthcharge.elf"
	else
		depthcharge_elf="${froot}/depthcharge/depthcharge.ro.elf"
	fi

	einfo "Building RO image."
	cros_bundle_firmware ${common[@]} \
		--coreboot-elf="${depthcharge_elf}" \
		--outdir "out.ro" --output "image.bin" \
		--uboot "${uboot_file}" ||
		die "failed to build RO image."
	einfo "Building RW image."
	cros_bundle_firmware "${common[@]}" --force-rw \
		--coreboot-elf="${depthcharge_elf}" \
		--outdir "out.rw" --output "image.rw.bin" \
		--uboot "${uboot_file}" ||
		die "failed to build RW image."

	# Build a netboot image.
	#
	# The readonly payload is usually depthcharge and the read/write
	# payload is usually netboot. This way the netboot image can be used
	# to boot from USB through recovery mode if necessary.
	#
	# This doesn't work on systems which optionally run the video BIOS
	# and don't use early firmware selection, specifically link and lumpy,
	# because both depthcharge and netboot run in normal mode and
	# continuously reboot the machine to alternatively enable and disable
	# graphics. On those systems, netboot is used for both payloads.
	einfo "Building netboot image."
	local netboot_elf="${froot}/depthcharge/netboot.elf"
	local netboot_ro
	if ! use unified_depthcharge && ( use lumpy || use link ); then
		netboot_ro="${netboot_elf}"
	else
		netboot_ro="${depthcharge_elf}"
	fi
	cros_bundle_firmware "${common[@]}" \
		--force-rw \
		--coreboot-elf="${netboot_ro}" \
		--outdir "out.net" --output "image.net.bin" \
		--uboot "${netboot_file}" ||
		die "failed to build netboot image."

	# Set convenient netboot parameter defaults for developers.
	local bootfile="${PORTAGE_USERNAME}/${BOARD_USE}/vmlinuz"
	local argsfile="${PORTAGE_USERNAME}/${BOARD_USE}/cmdline"
	${S}/setup/update_firmware_settings.py -i "image.net.bin" \
		--bootfile="${bootfile}" --argsfile="${argsfile}" ||
		die "failed to preset netboot parameter defaults."
	einfo "Netboot configured to boot ${bootfile}, fetch kernel command" \
		  "line from ${argsfile}, and use the DHCP-provided TFTP server IP."
}

src_compile() {
	if use depthcharge; then
		src_compile_depthcharge
	else
		src_compile_uboot
	fi
}

src_install() {
	local updated_fdt d

	insinto "${CROS_FIRMWARE_IMAGE_DIR}"
	doins *image*.bin

	if use depthcharge; then
		return
	fi

	insinto "${CROS_FIRMWARE_IMAGE_DIR}/dtb/updated"
	for d in out-*; do
		updated_fdt="${d}/updated.dtb"
		if [[ -f "${updated_fdt}" ]]; then
			newins  "${updated_fdt}" "${d#out-*}.dtb"
		fi
	done
}

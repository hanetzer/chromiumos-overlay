# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

# need to check out factory source for update_firmware_settings.py for now
CROS_WORKON_COMMIT="79f460bbac99c4aae1a530bc00a947799e814f72"
CROS_WORKON_TREE="6ccca2b34aaa68faa13f6feb01b5fb24fadf946f"
CROS_WORKON_PROJECT="chromiumos/platform/factory"
CROS_WORKON_LOCALNAME="../platform/factory"

inherit cros-debug cros-workon

DESCRIPTION="ChromeOS firmware image builder"
HOMEPAGE="http://www.chromium.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
# TODO(sjg@chromium.org): Remove when x86 can build all boards
BOARDS="alex aplrvp auron bayleybay beltino bolt butterfly"
BOARDS="${BOARDS} chell cyan emeraldlake2 eve falco fox"
BOARDS="${BOARDS} gizmo glados jecht kunimitsu link lumpy lumpy64 mario panther"
BOARDS="${BOARDS} parrot peppy pyro rambi reef samus sklrvp slippy snappy squawks stout strago"
BOARDS="${BOARDS} stumpy sumo"
IUSE="${BOARDS} +bmpblk build-all-fw cb_legacy_seabios cb_legacy_uboot"
IUSE="${IUSE} cros_ec efs exynos fsp"
IUSE="${IUSE} memtest pd_sync spring tegra vboot2 fastboot"

REQUIRED_USE="
	^^ ( ${BOARDS} arm mips )
"

DEPEND="
	exynos? ( sys-boot/exynos-pre-boot )
	tegra? ( virtual/tegra-bct )
	cros_ec? ( chromeos-base/chromeos-ec )
	pd_sync? ( chromeos-base/chromeos-ec )
	chromeos-base/vboot_reference
	bmpblk? ( sys-boot/chromeos-bmpblk )
	memtest? ( sys-boot/chromeos-memtest )
	cb_legacy_uboot? ( virtual/u-boot )
	cb_legacy_seabios? ( sys-boot/chromeos-seabios )
	sys-boot/coreboot
	sys-boot/depthcharge
	"

# Directory where the generated files are looked for and placed.
CROS_FIRMWARE_IMAGE_DIR="/firmware"
CROS_FIRMWARE_ROOT="${ROOT%/}${CROS_FIRMWARE_IMAGE_DIR}"
PD_FIRMWARE_DIR="${CROS_FIRMWARE_ROOT}/${PD_FIRMWARE}"

prepare_legacy_image() {
	local legacy_var="$1"
	if use cb_legacy_seabios; then
		eval "${legacy_var}='${CROS_FIRMWARE_ROOT}/seabios.cbfs'"
	elif use cb_legacy_uboot; then
		local output="${T}/_u-boot.cbfs"
		"${FILESDIR}/build_cb_legacy_uboot.sh" \
			"${CROS_FIRMWARE_ROOT}/u-boot" \
			"${CROS_FIRMWARE_ROOT}/dtb/${U_BOOT_FDT_USE}.dtb" \
			"${T}" "${output}" ||
			die "Failed to build legacy U-Boot."
		eval "${legacy_var}='${output}'"
	else
		einfo "No legacy boot payloads specified."
	fi
}

src_compile() {
	local froot="${CROS_FIRMWARE_ROOT}"
	# Location of various files

	local ec_file="${froot}/ec.RW.bin"
	local devkeys_file="${ROOT%/}/usr/share/vboot/devkeys"
	local fdt_file="${froot}/dts/fmap.dts"
	local coreboot_file="${froot}/coreboot.rom"

	local depthcharge_binaries=( --coreboot-elf
		"${froot}/depthcharge/depthcharge.elf" )
	local dev_binaries=( --coreboot-elf
		"${froot}/depthcharge/dev.elf" )

	local common=(
		--board "${BOARD_USE}"
		--key "${devkeys_file}"
		--dt "${fdt_file}"
	)

	local serial=( --coreboot "${coreboot_file}.serial" )
	local silent=( --coreboot "${coreboot_file}" )

	# cros_bundle_firmare was written with an assumption that
	# u-boot is always a part of the image. So, unless -D is
	# given, in case there is no explicit --uboot option in the
	# command line, cros_bundle_firmware assumes implicit
	# "--uboot /buils/<board>/fimrware/u-boot.bin"
	# which messes up the multicbfs case.
	#
	# Do not bundle defaults, but state the "skeleton" from which to take
	# IFD data and non-BIOS partitions on x86.
	common+=( -D --skeleton=${froot}/coreboot.rom )

	local legacy_file=""
	prepare_legacy_image legacy_file
	if [ -n "${legacy_file}" ]; then
		einfo "Using legacy boot payload: ${legacy_file}"
		if [ -f "${legacy_file}.serial" ]; then
			serial+=( --seabios "${legacy_file}.serial" )
			silent+=( --seabios "${legacy_file}" )
		else
			common+=( --seabios "${legacy_file}" )
		fi
	fi

	# bitmaps will be installed through --rocbfs-files
	common+=( --rocbfs-files "${froot}/rocbfs" )
	serial+=( --gbb-flags "+enable-serial" )
	einfo "Building production image."
	cros_bundle_firmware ${common[@]} ${silent[@]} \
		--outdir "out.ro" --output "image.bin" \
		${depthcharge_binaries[@]} || \
	  die "failed to build production image."
	einfo "Building serial image."
	COREBOOT_VARIANT=.serial \
	cros_bundle_firmware ${common[@]} ${serial[@]} \
		--outdir "out.serial" --output "image.serial.bin" \
		${depthcharge_binaries[@]} || \
	  die "failed to build serial image."
	einfo "Building developer image."
	COREBOOT_VARIANT=.serial \
	cros_bundle_firmware ${common[@]} ${serial[@]} \
		--outdir "out.dev" --output "image.dev.bin" \
		${dev_binaries[@]} || die "failed to build developer image."

	# Build a netboot image.
	#
	# The readonly payload is usually depthcharge and the read/write
	# payload is usually netboot. This way the netboot image can be used
	# to boot from USB through recovery mode if necessary.
	einfo "Building netboot image."
	local netboot_rw
	netboot_rw="${froot}/depthcharge/netboot.elf"
	local netboot_ro
	netboot_ro="${froot}/depthcharge/depthcharge.elf"
	COREBOOT_VARIANT=.serial \
	cros_bundle_firmware "${common[@]}" "${serial[@]}" \
		--coreboot-elf="${netboot_ro}" \
		--outdir "out.net" --output "image.net.bin" \
		--uboot "${netboot_rw}" ||
		die "failed to build netboot image."

	# Set convenient netboot parameter defaults for developers.
	local bootfile="${PORTAGE_USERNAME}/${BOARD_USE}/vmlinuz"
	local argsfile="${PORTAGE_USERNAME}/${BOARD_USE}/cmdline"
	"${S}"/setup/update_firmware_settings.py -i "image.net.bin" \
		--bootfile="${bootfile}" --argsfile="${argsfile}" &&
		"${S}"/setup/update_firmware_settings.py -i "image.dev.bin" \
			--bootfile="${bootfile}" --argsfile="${argsfile}" ||
		die "failed to preset netboot parameter defaults."
	einfo "Netboot configured to boot ${bootfile}, fetch kernel command" \
		  "line from ${argsfile}, and use the DHCP-provided TFTP server IP."

	# Build fastboot image
	if use fastboot ; then

		local fastboot_rw
		# Currently, rw image does not need to have any fastboot functionality.
		# Thus, use the normal depthcharge image compiled without fastboot mode.
		fastboot_rw="${froot}/depthcharge/depthcharge.elf"

		local fastboot_ro
		fastboot_ro="${froot}/depthcharge/fastboot.elf"

		einfo "Building fastboot image."
		COREBOOT_VARIANT=.serial \
		cros_bundle_firmware "${common[@]}" "${serial[@]}" \
			--coreboot-elf="${fastboot_ro}" \
			--outdir "out.fastboot" --output "image.fastboot.bin" \
			--uboot "${fastboot_rw}" \
			|| die "failed to build fastboot image."

		einfo "Building fastboot production image."
		cros_bundle_firmware "${common[@]}" "${silent[@]}" \
			--coreboot-elf "${fastboot_ro}" \
			--outdir "out.ro.fastboot" --output "image.fastboot-prod.bin" \
			--uboot "${fastboot_rw}" \
			|| die "failed to build fastboot production image."

	fi
}

src_install() {
	local updated_fdt d

	insinto "${CROS_FIRMWARE_IMAGE_DIR}"
	doins *image*.bin
}

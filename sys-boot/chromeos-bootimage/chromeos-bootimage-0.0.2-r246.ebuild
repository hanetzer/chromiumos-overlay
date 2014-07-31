# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

# need to check out factory source for update_firmware_settings.py for now
CROS_WORKON_COMMIT="b832ef176dd09667534ff6b3d1e585c3f864a97b"
CROS_WORKON_TREE="9acac455bb6ff6df78d5252598ae403ebfe39dd7"
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
IUSE="${BOARDS} build-all-fw exynos factory-mode memtest tegra cros_ec efs vboot2"
IUSE="${IUSE} depthcharge unified_depthcharge spring"
IUSE="${IUSE} cb_legacy_seabios cb_legacy_uboot pd_sync"

REQUIRED_USE="^^ ( ${BOARDS} arm )"

COREBOOT_DEPEND="
	sys-apps/coreboot-utils
	sys-boot/coreboot
"
X86_DEPEND="
	${COREBOOT_DEPEND}
"
DEPEND="
	exynos? ( sys-boot/exynos-pre-boot )
	tegra? ( virtual/tegra-bct )
	x86? ( ${X86_DEPEND} )
	amd64? ( ${X86_DEPEND} )
	!depthcharge? ( virtual/u-boot )
	cros_ec? ( chromeos-base/chromeos-ec )
	pd_sync? ( chromeos-base/chromeos-ec )
	chromeos-base/vboot_reference
	sys-boot/chromeos-bmpblk
	memtest? ( sys-boot/chromeos-memtest )
	depthcharge? ( ${COREBOOT_DEPEND} sys-boot/depthcharge )
	cb_legacy_uboot? ( virtual/u-boot )
	cb_legacy_seabios? ( sys-boot/chromeos-seabios )
	"

# Directory where the generated files are looked for and placed.
CROS_FIRMWARE_IMAGE_DIR="/firmware"
CROS_FIRMWARE_ROOT="${ROOT%/}${CROS_FIRMWARE_IMAGE_DIR}"
PD_FIRMWARE_DIR="${CROS_FIRMWARE_ROOT}/${PD_FIRMWARE}"

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
	if use pd_sync; then
		common_flags+=" --pd ${PD_FIRMWARE_DIR}/ec.RW.bin"
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
	local romstage_file="${froot}/romstage.stage"
	local ramstage_file="${froot}/ramstage.stage"
	local refcode_file="${froot}/refcode.stage"

	local ro_suffix
	local rw_suffix

	if use unified_depthcharge; then
		ro_suffix="elf"
		rw_suffix="payload"
	else
		ro_suffix="ro.elf"
		rw_suffix="rw.bin"
	fi

	local common=(
		--board "${BOARD_USE}"
		--key "${devkeys_file}"
		--bmpblk "${bmpblk_file}"
		--dt "${fdt_file}"
	)

	local serial=( --coreboot "${coreboot_file}.serial" )
	local silent=( --coreboot "${coreboot_file}" )

	# If unified depthcharge is being used always include ramstage_file.
	if use unified_depthcharge; then
		if use vboot2 && [ "${BOARD_USE}" = "nyan_blaze" ]; then
			serial+=( --add-blob romstage "${romstage_file}.serial" )
			silent+=( --add-blob romstage "${romstage_file}" )
		fi
		serial+=( --add-blob ramstage "${ramstage_file}.serial" )
		silent+=( --add-blob ramstage "${ramstage_file}" )
	fi

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

	if ( use x86 || use amd64 ) && [ -f "${refcode_file}" ]; then
		common+=( --add-blob refcode "${refcode_file}" )
	fi

	if use cros_ec; then
		common+=( --ec "${ec_file}" )
	fi

	if use pd_sync; then
		common+=( --pd "${froot}/${PD_FIRMWARE}/ec.RW.bin")
	fi

	einfo "Building production image."
	cros_bundle_firmware ${common[@]} ${silent[@]} \
		--coreboot-elf="${froot}/depthcharge/depthcharge.${ro_suffix}" \
		--outdir "out.ro" --output "image.bin" \
		--uboot "${froot}/depthcharge/depthcharge.${rw_suffix}" ||
		die "failed to build production image."
	einfo "Building forced RW image."
	cros_bundle_firmware "${common[@]}" ${silent[@]} --force-rw \
		--coreboot-elf="${froot}/depthcharge/depthcharge.${ro_suffix}" \
		--outdir "out.rw" --output "image.rw.bin" \
		--uboot "${froot}/depthcharge/depthcharge.${rw_suffix}" ||
		die "failed to build forced RW image."
	einfo "Building serial image."
	cros_bundle_firmware ${common[@]} ${serial[@]} \
		--coreboot-elf="${froot}/depthcharge/depthcharge.${ro_suffix}" \
		--outdir "out.serial" --output "image.serial.bin" \
		--uboot "${froot}/depthcharge/depthcharge.${rw_suffix}" ||
		die "failed to build serial image."
	einfo "Building developer image."
	cros_bundle_firmware ${common[@]} ${serial[@]} \
		--coreboot-elf="${froot}/depthcharge/dev.${ro_suffix}" \
		--outdir "out.dev" --output "image.dev.bin" \
		--uboot "${froot}/depthcharge/dev.${rw_suffix}" ||
		die "failed to build developer image."

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
	local netboot_rw
	if use unified_depthcharge; then
		netboot_rw="${froot}/depthcharge/netboot.payload"
	else
		netboot_rw="${froot}/depthcharge/netboot.bin"
	fi
	local netboot_ro
	if ! use unified_depthcharge && ( use lumpy || use link ); then
		netboot_ro="${froot}/depthcharge/netboot.elf"
	else
		netboot_ro="${froot}/depthcharge/depthcharge.${ro_suffix}"
	fi
	cros_bundle_firmware "${common[@]}" "${serial[@]}" \
		--force-rw \
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

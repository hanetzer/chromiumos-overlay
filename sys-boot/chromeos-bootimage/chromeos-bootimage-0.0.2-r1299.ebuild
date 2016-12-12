# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

# need to check out factory source for update_firmware_settings.py for now
CROS_WORKON_COMMIT="1f26d62d9f425ab00b7b3d3c439d2b5021cceb53"
CROS_WORKON_TREE="ce70857c9bf8293f100d8882258bbe82189d2b07"
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
BOARDS="${BOARDS} parrot peppy poppy pyro rambi reef samus sklrvp slippy snappy"
BOARDS="${BOARDS} squawks stout strago stumpy sumo"
IUSE="${BOARDS} +bmpblk cb_legacy_seabios cb_legacy_uboot"
IUSE="${IUSE} cros_ec exynos fsp"
IUSE="${IUSE} pd_sync tegra fastboot"

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

sign_region() {
	local fw_image=$1
	local keydir=$2
	local slot=$3

	local tmpfile=`mktemp`
	local cbfs=FW_MAIN_${slot}
	local vblock=VBLOCK_${slot}

	cbfstool ${fw_image} read -r ${cbfs} -f ${tmpfile} 2>/dev/null
	local size=$(cbfstool ${fw_image} print -k -r ${cbfs} | \
		tail -1 | \
		sed "/(empty).*null/ s,^(empty)[[:space:]]\(0x[0-9a-f]*\)\tnull\t.*$,\1,")
	size=$(printf "%d" ${size})

	if [ -n "${size}" ] && [ ${size} -gt 0 ]; then
		einfo "truncate ${cbfs} to ${size}"
		head -c ${size} ${tmpfile} > ${tmpfile}.2
		mv ${tmpfile}.2 ${tmpfile}
		cbfstool ${fw_image} write --force -u -i 0 \
			-r ${cbfs} -f ${tmpfile} 2>/dev/null
	fi

	futility vbutil_firmware \
		--vblock ${tmpfile}.out \
		--keyblock ${keydir}/firmware.keyblock \
		--signprivate ${keydir}/firmware_data_key.vbprivk \
		--version 1 \
		--fv ${tmpfile} \
		--kernelkey ${keydir}/kernel_subkey.vbpubk \
		--flags 0

	cbfstool ${fw_image} write -u -i 0 -r ${vblock} -f ${tmpfile}.out 2>/dev/null

	rm -f ${tmpfile} ${tmpfile}.out
}

sign_image() {
	local fw_image=$1
	local keydir=$2

	sign_region "${fw_image}" "${keydir}" A
	sign_region "${fw_image}" "${keydir}" B
}

add_payloads() {
	local fw_image=$1
	local ro_payload=$2
	local rw_payload=$3

	cbfstool ${fw_image} add-payload \
		-f ${ro_payload} -n fallback/payload -c lzma

	cbfstool ${fw_image} add-payload \
		-f ${rw_payload} -n fallback/payload -c lzma -r FW_MAIN_A,FW_MAIN_B
}

src_compile() {
	local froot="${CROS_FIRMWARE_ROOT}"
	# Location of various files

	local ec_file="${froot}/ec.RW.bin"
	local devkeys_file="${ROOT%/}/usr/share/vboot/devkeys"
	local coreboot_file="${froot}/coreboot.rom"

	local depthcharge_binaries=( --coreboot-elf
		"${froot}/depthcharge/depthcharge.elf" )
	local dev_binaries=( --coreboot-elf
		"${froot}/depthcharge/dev.elf" )

	local common=(
		--board "${BOARD_USE}"
		--key "${devkeys_file}"
	)

	cp ${coreboot_file}.serial assembly_coreboot.rom.serial
	cp ${coreboot_file} assembly_coreboot.rom

	# files from rocbfs/ are installed in all images' RO CBFS
	for file in ${froot}/rocbfs/*; do
		for rom in assembly_coreboot.rom{,.serial}; do
			cbfstool ${rom} add \
				-r COREBOOT \
				-f $file -n $(basename $file) -t raw \
				-c lzma 2>/dev/null
		done
	done

	local legacy_file=""
	prepare_legacy_image legacy_file
	if [ -n "${legacy_file}" ]; then
		einfo "Using legacy boot payload: ${legacy_file}"
		if [ -f "${legacy_file}.serial" ]; then
			cbfstool assembly_coreboot.rom.serial write \
				-f ${legacy_file}.serial --force -r RW_LEGACY 2>/dev/null
			cbfstool assembly_coreboot.rom write \
				-f ${legacy_file} --force -r RW_LEGACY 2>/dev/null
		else
			cbfstool assembly_coreboot.rom.serial write \
				-f ${legacy_file} --force -r RW_LEGACY 2>/dev/null
			cbfstool assembly_coreboot.rom write \
				-f ${legacy_file} --force -r RW_LEGACY 2>/dev/null
		fi
	fi

	local serial=( --coreboot "assembly_coreboot.rom.serial" )
	local silent=( --coreboot "assembly_coreboot.rom" )

	einfo "Building production image."
	cp assembly_coreboot.rom image.bin
	add_payloads image.bin ${froot}/depthcharge/depthcharge.elf \
		${froot}/depthcharge/depthcharge.elf
	sign_image image.bin "${devkeys_file}"

	einfo "Building serial image."
	cp assembly_coreboot.rom.serial image.serial.bin
	add_payloads image.serial.bin ${froot}/depthcharge/depthcharge.elf \
		${froot}/depthcharge/depthcharge.elf
	sign_image image.serial.bin "${devkeys_file}"

	einfo "Building developer image."
	cp assembly_coreboot.rom.serial image.dev.bin
	add_payloads image.dev.bin ${froot}/depthcharge/dev.elf \
		${froot}/depthcharge/dev.elf
	sign_image image.dev.bin "${devkeys_file}"

	# Build a netboot image.
	#
	# The readonly payload is usually depthcharge and the read/write
	# payload is usually netboot. This way the netboot image can be used
	# to boot from USB through recovery mode if necessary.
	einfo "Building netboot image."
	cp assembly_coreboot.rom.serial image.net.bin
	add_payloads image.net.bin ${froot}/depthcharge/netboot.elf \
		${froot}/depthcharge/depthcharge.elf
	sign_image image.net.bin "${devkeys_file}"

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
		cp assembly_coreboot.rom.serial image.fastboot.bin
		add_payloads image.fastboot.bin ${froot}/depthcharge/fastboot.elf \
			${froot}/depthcharge/depthcharge.elf
		sign_image image.fastboot.bin "${devkeys_file}"

		einfo "Building fastboot production image."
		cp assembly_coreboot.rom image.fastboot-prod.bin
		add_payloads image.fastboot-prod.bin ${froot}/depthcharge/fastboot.elf \
			${froot}/depthcharge/depthcharge.elf
		sign_image image.fastboot-prod.bin "${devkeys_file}"

	fi
}

src_install() {
	local updated_fdt d

	insinto "${CROS_FIRMWARE_IMAGE_DIR}"
	doins *image*.bin
}

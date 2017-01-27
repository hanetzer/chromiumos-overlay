# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

# need to check out factory source for update_firmware_settings.py for now
CROS_WORKON_PROJECT="chromiumos/platform/factory"
CROS_WORKON_LOCALNAME="../platform/factory"

inherit cros-debug cros-workon

DESCRIPTION="ChromeOS firmware image builder"
HOMEPAGE="http://www.chromium.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~*"
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

do_cbfstool() {
	local output
	output=$(cbfstool "$@" 2>&1)
	if [ $? != 0 ]; then
		die "Failed cbfstool invocation: cbfstool $@\n${output}"
	fi
	printf "${output}"
}

sign_region() {
	local fw_image=$1
	local keydir=$2
	local slot=$3

	local tmpfile=`mktemp`
	local cbfs=FW_MAIN_${slot}
	local vblock=VBLOCK_${slot}

	do_cbfstool ${fw_image} read -r ${cbfs} -f ${tmpfile}
	local size=$(do_cbfstool ${fw_image} print -k -r ${cbfs} | \
		tail -1 | \
		sed "/(empty).*null/ s,^(empty)[[:space:]]\(0x[0-9a-f]*\)\tnull\t.*$,\1,")
	size=$(printf "%d" ${size})

	# If the last entry is called "(empty)" and of type "null", remove it from
	# the section so it isn't part of the signed data, to improve boot speed
	# if (as often happens) there's a large unused suffix.
	if [ -n "${size}" ] && [ ${size} -gt 0 ]; then
		head -c ${size} ${tmpfile} > ${tmpfile}.2
		mv ${tmpfile}.2 ${tmpfile}
		do_cbfstool ${fw_image} write --force -u -i 0 \
			-r ${cbfs} -f ${tmpfile}
	fi

	futility vbutil_firmware \
		--vblock ${tmpfile}.out \
		--keyblock ${keydir}/firmware.keyblock \
		--signprivate ${keydir}/firmware_data_key.vbprivk \
		--version 1 \
		--fv ${tmpfile} \
		--kernelkey ${keydir}/kernel_subkey.vbpubk \
		--flags 0

	do_cbfstool ${fw_image} write -u -i 0 -r ${vblock} -f ${tmpfile}.out

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

	do_cbfstool ${fw_image} add-payload \
		-f ${ro_payload} -n fallback/payload -c lzma

	do_cbfstool ${fw_image} add-payload \
		-f ${rw_payload} -n fallback/payload -c lzma -r FW_MAIN_A,FW_MAIN_B
}

# Add payloads and sign the image.
# This takes the base image and creates a new signed one with the given
# payloads added to it.
# Args:
#   $1: Public name to use in info message.
#   $2: Source image to start from.
#   $3: Image type (e,g. "" for standard image, "dev" for dev image)
#   $4: Payload to add to read-only image portion
#   $5: Payload to add to read-write image portion
#   $6: Directory containing developer keys (used for signing)
build_image() {
	local public_name=$1
	local src_image=$2
	local image_type=$3
	local ro_payload=$4
	local rw_payload=$5
	local devkeys_dir=$6

	[ -n "${image_type}" ] && image_type=".${image_type}"
	local dst_image="image${image_type}.bin"

	einfo "Building ${public_name} image ${dst_image}"
	cp ${src_image} ${dst_image}
	add_payloads ${dst_image} ${ro_payload} ${rw_payload}
	sign_image ${dst_image} "${devkeys_dir}"
}

# Build firmware images for a given board
# Creates image*.bin for the following images:
#    image.bin          - production image (no serial console)
#    image.serial.bin   - production image with serial console enabled
#    image.dev.bin      - developer image with serial console enabled
#    image.net.bin      - netboot image with serial console enabled
#    image.fastboot.bin - fastboot image with serial console enabled
#    image.fastboot-prod.bin - fastboot image (no serial console)
#
# Args:
#   $1: Directory containing the input files:
#       coreboot.rom             - coreboot ROM image containing various pieces
#       coreboot.rom.serial      - same, but with serial console enabled
#       depthcharge/depthcharge.elf - depthcharge ELF payload
#       depthcharge/dev.elf      - developer version of depthcharge
#       depthcharge/netboot.elf  - netboot version of depthcharge
#       depthcharge/fastboot.elf - fastboot version of depthcharge
#       rocbfs/*                 - fonts, images and screens for recovery mode
build_images() {
	local froot="$1"

	local devkeys="${ROOT%/}/usr/share/vboot/devkeys"
	local coreboot_file="${froot}/coreboot.rom"

	cp ${coreboot_file} coreboot.rom
	cp ${coreboot_file}.serial coreboot.rom.serial
	coreboot_file=coreboot.rom

	for file in $(find compressed-assets -type f 2>/dev/null); do
		for rom in ${coreboot_file}{,.serial}; do
			do_cbfstool ${rom} add \
				-r COREBOOT \
				-f $file -n $(basename $file) -t raw \
				-c precompression
		done
	done

	local legacy_file=""
	prepare_legacy_image legacy_file
	if [ -n "${legacy_file}" ]; then
		einfo "Using legacy boot payload: ${legacy_file}"
		if [ -f "${legacy_file}.serial" ]; then
			do_cbfstool ${coreboot_file}.serial write \
				-f ${legacy_file}.serial --force -r RW_LEGACY
			do_cbfstool ${coreboot_file} write \
				-f ${legacy_file} --force -r RW_LEGACY
		else
			do_cbfstool ${coreboot_file}.serial write \
				-f ${legacy_file} --force -r RW_LEGACY
			do_cbfstool ${coreboot_file} write \
				-f ${legacy_file} --force -r RW_LEGACY
		fi
	fi

	local depthcharge="${froot}/depthcharge/depthcharge.elf"
	local depthcharge_dev="${froot}/depthcharge/dev.elf"
	local netboot="${froot}/depthcharge/netboot.elf"
	local fastboot="${froot}/depthcharge/fastboot.elf"

	build_image "production" "${coreboot_file}" "" \
		"${depthcharge}" "${depthcharge}" "${devkeys}"

	build_image "serial" "${coreboot_file}.serial" serial \
		"${depthcharge}" "${depthcharge}" "${devkeys}"

	build_image "developer" "${coreboot_file}.serial" dev \
		"${depthcharge_dev}" "${depthcharge_dev}" "${devkeys}"

	# Build a netboot image.
	#
	# The readonly payload is usually depthcharge and the read/write
	# payload is usually netboot. This way the netboot image can be used
	# to boot from USB through recovery mode if necessary.
	build_image "netboot" "${coreboot_file}.serial" net \
		"${depthcharge}" "${netboot}" "${devkeys}"

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

	if use fastboot ; then
		build_image "fastboot" "${coreboot_file}.serial" fastboot \
			"${fastboot}" "${depthcharge}" "${devkeys}"

		build_image "fastboot production" "${coreboot_file}" \
			fastboot-prod \
			"${fastboot}" "${depthcharge}" "${devkeys}"
	fi
}

src_compile() {
	local froot="${CROS_FIRMWARE_ROOT}"

	einfo "Compressing static assets"
	# files from rocbfs/ are installed in all images' RO CBFS
	mkdir compressed-assets
	find ${froot}/rocbfs -mindepth 1 -maxdepth 1 -printf "%P\0" 2>/dev/null | \
		xargs -0 -n 1 -P $(nproc) -I '{}' \
		cbfs-compression-tool compress ${froot}/rocbfs/'{}' \
			compressed-assets/'{}' LZMA

	build_images "${froot}"
}

src_install() {
	insinto "${CROS_FIRMWARE_IMAGE_DIR}"
	doins image*.bin
}

# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

inherit cros-debug cros-unibuild

DESCRIPTION="ChromeOS firmware image builder"
HOMEPAGE="http://www.chromium.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
# TODO(sjg@chromium.org): Remove when x86 can build all boards
BOARDS="alex aplrvp atlas auron bayleybay beltino bolt butterfly"
BOARDS="${BOARDS} chell cnlrvp coral cyan emeraldlake2 eve falco fizz fox"
BOARDS="${BOARDS} glados glkrvp grunt jecht kahlee kblrvp kunimitsu link"
BOARDS="${BOARDS} lumpy lumpy64 mario meowth nasher nami nautilus octopus"
BOARDS="${BOARDS} panther parrot peppy poppy pyro rambi reef samus"
BOARDS="${BOARDS} sand sklrvp slippy snappy"
BOARDS="${BOARDS} soraka squawks stout strago stumpy sumo zoombini"
IUSE="${BOARDS} cb_legacy_seabios cb_legacy_tianocore cb_legacy_uboot"
IUSE="${IUSE} fsp fastboot unibuild"

REQUIRED_USE="
	^^ ( ${BOARDS} arm mips )
"

DEPEND="
	sys-boot/coreboot
	sys-boot/depthcharge
	sys-boot/chromeos-bmpblk
	cb_legacy_seabios? ( sys-boot/chromeos-seabios )
	cb_legacy_tianocore? ( sys-boot/edk2 )
	cb_legacy_uboot? ( virtual/u-boot )
	unibuild? ( chromeos-base/chromeos-config )
	"

# Directory where the generated files are looked for and placed.
CROS_FIRMWARE_IMAGE_DIR="/firmware"
CROS_FIRMWARE_ROOT="${ROOT%/}${CROS_FIRMWARE_IMAGE_DIR}"

S=${WORKDIR}

prepare_legacy_image() {
	local legacy_var="$1"
	if use cb_legacy_tianocore; then
		export "${legacy_var}=${CROS_FIRMWARE_ROOT}/tianocore.cbfs"
	elif use cb_legacy_seabios; then
		export "${legacy_var}=${CROS_FIRMWARE_ROOT}/seabios.cbfs"
	elif use cb_legacy_uboot; then
		local output="${T}/_u-boot.cbfs"
		"${FILESDIR}/build_cb_legacy_uboot.sh" \
			"${CROS_FIRMWARE_ROOT}/u-boot" \
			"${CROS_FIRMWARE_ROOT}/dtb/${U_BOOT_FDT_USE}.dtb" \
			"${T}" "${output}" ||
			die "Failed to build legacy U-Boot."
		export "${legacy_var}=${output}"
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
# The image is placed in directory ${outdir} ("" for current directory).
# An image suffix is added is ${suffix} is non-empty (e.g. "dev", "net").
# Args:
#   $1: Image type (e,g. "" for standard image, "dev" for dev image)
#   $2: Source image to start from.
#   $3: Payload to add to read-only image portion
#   $4: Payload to add to read-write image portion
build_image() {
	local image_type=$1
	local src_image=$2
	local ro_payload=$3
	local rw_payload=$4
	local devkeys_dir="${ROOT%/}/usr/share/vboot/devkeys"

	[ -n "${image_type}" ] && image_type=".${image_type}"
	local dst_image="${outdir}image${suffix}${image_type}.bin"

	einfo "Building image ${dst_image}"
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
# If $2 is set, then it uses "image-$2" instead of "image" and puts images in
# the $2 subdirectory.
#
# If outdir
# Args:
#   $1: Directory containing the input files:
#       coreboot.rom             - coreboot ROM image containing various pieces
#       coreboot.rom.serial      - same, but with serial console enabled
#       depthcharge/depthcharge.elf - depthcharge ELF payload
#       depthcharge/dev.elf      - developer version of depthcharge
#       depthcharge/netboot.elf  - netboot version of depthcharge
#       depthcharge/fastboot.elf - fastboot version of depthcharge
#       compressed-assets/*      - fonts, images and screens for recovery mode
#                                  originally from rocbfs/*, pre-compressed
#                                  in src_compile
#       cbfs/*                   - files to add to all three CBFS regions,
#                                  uncompressed
#   $2: Name to use when naming output files (see note above, can be empty)
#
#   $3: Name of target to build for coreboot (can be empty)
#
#   $4: Name of target to build for depthcharge (can be empty)
build_images() {
	local froot="$1"
	local build_name="$2"
	local coreboot_build_target="$3"
	local depthcharge_build_target="$4"
	local outdir
	local suffix

	local coreboot_file
	local depthcharge_prefix

	if [ -n "${build_name}" ]; then
		einfo "Building firmware images for ${build_name}"
		outdir="${build_name}/"
		mkdir "${outdir}"
		suffix="-${build_name}"
		coreboot_file="${froot}/${coreboot_build_target}/coreboot.rom"
		depthcharge_prefix="${froot}/${depthcharge_build_target}"
	else
		coreboot_file="${froot}/coreboot.rom"
		depthcharge_prefix="${froot}"
	fi

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

	# files from cbfs/ are installed in all CBFS regions, uncompressed
	for file in $(find "${CROS_FIRMWARE_ROOT}/cbfs" -type f 2>/dev/null); do
		for rom in ${coreboot_file}{,.serial}; do
			do_cbfstool ${rom} add \
				-r COREBOOT,FW_MAIN_A,FW_MAIN_B \
				-f $file -n $(basename $file) -t raw
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

	local depthcharge="${depthcharge_prefix}/depthcharge/depthcharge.elf"
	local depthcharge_dev="${depthcharge_prefix}/depthcharge/dev.elf"
	local netboot="${depthcharge_prefix}/depthcharge/netboot.elf"
	local fastboot="${depthcharge_prefix}/depthcharge/fastboot.elf"

	build_image "" "${coreboot_file}" "${depthcharge}" "${depthcharge}"

	build_image serial "${coreboot_file}.serial" \
		"${depthcharge}" "${depthcharge}"

	build_image dev "${coreboot_file}.serial" \
		"${depthcharge_dev}" "${depthcharge_dev}"

	# Build a netboot image.
	#
	# The readonly payload is usually depthcharge and the read/write
	# payload is usually netboot. This way the netboot image can be used
	# to boot from USB through recovery mode if necessary.
	build_image net "${coreboot_file}.serial" "${depthcharge}" "${netboot}"

	# Set convenient netboot parameter defaults for developers.
	local bootfile="${PORTAGE_USERNAME}/${BOARD_USE}/vmlinuz"
	local argsfile="${PORTAGE_USERNAME}/${BOARD_USE}/cmdline"
	netboot_firmware_settings.py \
		-i "${outdir}image${suffix}.net.bin" \
		--bootfile="${bootfile}" --argsfile="${argsfile}" &&
		netboot_firmware_settings.py \
			-i "${outdir}image${suffix}.dev.bin" \
			--bootfile="${bootfile}" --argsfile="${argsfile}" ||
		die "failed to preset netboot parameter defaults."
	einfo "Netboot configured to boot ${bootfile}, fetch kernel command" \
		"line from ${argsfile}, and use the DHCP-provided TFTP server IP."

	if use fastboot ; then
		build_image fastboot "${coreboot_file}.serial" \
			"${fastboot}" "${depthcharge}"

		build_image fastboot-prod "${coreboot_file}" \
			"${fastboot}" "${depthcharge}"
	fi
}

src_compile() {
	local froot="${CROS_FIRMWARE_ROOT}"
	einfo "Compressing static assets"
	# files from rocbfs/ are installed in all images' RO CBFS, compressed
	mkdir compressed-assets
	find ${froot}/rocbfs -mindepth 1 -maxdepth 1 -printf "%P\0" 2>/dev/null | \
		xargs -0 -n 1 -P $(nproc) -I '{}' \
		cbfs-compression-tool compress ${froot}/rocbfs/'{}' \
			compressed-assets/'{}' LZMA

	if use unibuild; then
		local fields="coreboot,depthcharge"
		local cmd="get-firmware-build-combinations"
		(cros_config_host "${cmd}" "${fields}" || die) |
		while read -r name; do
			read -r coreboot
			read -r depthcharge
			einfo "Building image for: ${name}"
			build_images ${froot} ${name} ${coreboot} ${depthcharge}
		done
	else
		build_images "${froot}" "" "" ""
	fi
}

src_install() {
	insinto "${CROS_FIRMWARE_IMAGE_DIR}"
	if use unibuild; then
		local fields="coreboot,depthcharge"
		local cmd="get-firmware-build-combinations"
		(cros_config_host "${cmd}" "${fields}" || die) |
		while read -r name; do
			read -r coreboot
			read -r depthcharge
			doins "${name}"/image-${name}*.bin
		done
	else
		doins image*.bin
	fi
}

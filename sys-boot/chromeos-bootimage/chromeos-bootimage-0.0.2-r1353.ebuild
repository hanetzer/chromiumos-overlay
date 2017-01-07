# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

# need to check out factory source for update_firmware_settings.py for now
CROS_WORKON_COMMIT="9b7536b41b851927dc90681df57c391d8a81edd0"
CROS_WORKON_TREE="85b0acd5c78f6594e74b23644c53c73f3cee707a"
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

do_cbfstool() {
	local output
	output=$(cbfstool "$@" 2>&1)
	if [ $? != 0 ]; then
		die "Failed cbfstool invocation: cbfstool $@\n${output}"
	fi
	echo "${output}"
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

build_image() {
	local public_name=$1
	local src_image=$2
	local dst_image=$3
	local ro_payload=$4
	local rw_payload=$5
	local devkeys_dir=$6

	einfo "Building ${public_name} image."
	cp ${src_image} ${dst_image}
	add_payloads ${dst_image} ${ro_payload} ${rw_payload}
	sign_image ${dst_image} "${devkeys_dir}"
}

src_compile() {
	local froot="${CROS_FIRMWARE_ROOT}"
	# Location of various files

	local devkeys="${ROOT%/}/usr/share/vboot/devkeys"
	local coreboot_file="${froot}/coreboot.rom"

	cp ${coreboot_file} coreboot.rom
	cp ${coreboot_file}.serial coreboot.rom.serial
	coreboot_file=coreboot.rom

	einfo "Add static assets to images"
	# files from rocbfs/ are installed in all images' RO CBFS
	for file in $(ls -1d ${froot}/rocbfs/* 2>/dev/null); do
		for rom in ${coreboot_file}{,.serial}; do
			do_cbfstool ${rom} add \
				-r COREBOOT \
				-f $file -n $(basename $file) -t raw \
				-c lzma
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


	build_image "production" "${coreboot_file}" "image.bin" \
		"${depthcharge}" "${depthcharge}" "${devkeys}"

	build_image "serial" "${coreboot_file}.serial" "image.serial.bin" \
		"${depthcharge}" "${depthcharge}" "${devkeys}"

	build_image "developer" "${coreboot_file}.serial" "image.dev.bin" \
		"${depthcharge_dev}" "${depthcharge_dev}" "${devkeys}"

	# Build a netboot image.
	#
	# The readonly payload is usually depthcharge and the read/write
	# payload is usually netboot. This way the netboot image can be used
	# to boot from USB through recovery mode if necessary.
	build_image "netboot" "${coreboot_file}.serial" "image.net.bin" \
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
		build_image "fastboot" "${coreboot_file}.serial" "image.fastboot.bin" \
			"${fastboot}" "${depthcharge}" "${devkeys}"

		build_image "fastboot production" "${coreboot_file}" "image.fastboot-prod.bin" \
			"${fastboot}" "${depthcharge}" "${devkeys}"
	fi
}

src_install() {
	insinto "${CROS_FIRMWARE_IMAGE_DIR}"
	doins *image*.bin
}

# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit toolchain-funcs

DESCRIPTION="ChromeOS BIOS builder"
HOMEPAGE="http://www.chromium.org"
LICENSE=""
SLOT="0"
KEYWORDS="arm"
IUSE=""

RDEPEND=""
DEPEND="virtual/tegra-bct
	virtual/u-boot
	chromeos-base/vboot_reference
	"

keys="${ROOT%/}/usr/share/vboot/devkeys"
system_map="${ROOT%/}/u-boot/System.map"
autoconf="${ROOT%/}/u-boot/autoconf.mk"
stub_image="${ROOT%/}/u-boot/u-boot-stub.bin"
recovery_image="${ROOT%/}/u-boot/u-boot-recovery.bin"
normal_image="${ROOT%/}/u-boot/u-boot-normal.bin"
bct_file="${ROOT%/}/u-boot/board.bct"

get_autoconf() {
	grep -m1 $1 ${autoconf} | tr -d "\"" | cut -d = -f 2
	assert
}

get_text_base() {
	# Parse the TEXT_BASE value from the U-Boot System.map file.
	grep -m1 -E "^[0-9a-fA-F]{8} T _start$" ${system_map} | cut -d " " -f 1
	assert
}

get_screen_geometry() {
	col=$(get_autoconf CONFIG_LCD_vl_col)
	row=$(get_autoconf CONFIG_LCD_vl_row)
	echo "${col}x${row}!"
}

construct_layout() {
	grep -E 'CONFIG_FIRMWARE_SIZE' ${autoconf} ||
		die "Failed to extract firmware size."

	grep -E 'CONFIG_CHROMEOS_HWID' ${autoconf} ||
		die "Failed to extract HWID."

	grep -E 'CONFIG_(OFFSET|LENGTH)_\w+' ${autoconf} ||
		die "Failed to extract offsets and lengths."

	cat ${FILESDIR}/firmware_layout_config ||
		die "Failed to cat firmware_layout_config."
}

construct_config() {
	local text_base="0x$1"

	#
	# The cbootimage config file format is not yet documented.  Below is
	# a minimal config file that merges a BCT file and bootloader; in
	# this case our stub U-Boot image.  We do not use the Version, but it
	# needs to be set.
	#
	# Currently a bug in cbootimage prevents us from setting Redundancy to
	# 0.  Redundancy controls how many instances of the BCT should be
	# written to the signed image.  A value of 1 causes two instances to
	# be written.
	#
	# The BootLoader parameter specifies the bootloader image to use.  It
	# also specifies the load address for the bootloader in RAM and the
	# entry point of the resulting image.  For U-Boot these are the same
	# value (TEXT_BASE).
	#
	echo "Bctfile=${bct_file};"
	echo "Version=1;"
	echo "Redundancy=1;"
	echo "BootLoader=${stub_image},${text_base},${text_base},Complete;"
}

src_compile() {
	hwid=$(get_autoconf CONFIG_CHROMEOS_HWID)
        gbb_size=$(get_autoconf CONFIG_LENGTH_GBB)

	construct_layout > layout.py

        construct_config $(get_text_base) > boot.cfg ||
		die "Failed to create boot stub signing configuration file."

	/usr/share/vboot/bitmaps/make_bmp_images.sh \
		"${hwid}" \
		"$(get_screen_geometry)" \
		"arm"

	bmp_dir="out_${hwid// /_}"
	pushd "${bmp_dir}"
	bmpblk_utility -z 2 \
		-c ${FILESDIR}/firmware_screen_config.yaml \
		bmpblk.bin
	popd

	gbb_utility -c "0x100,0x1000,$((${gbb_size}-0x2180)),0x1000" gbb.bin ||
		die "Failed to create the GBB."

	gbb_utility -s \
		--hwid="${hwid}" \
		--rootkey=${keys}/root_key.vbpubk \
		--recoverykey=${keys}/recovery_key.vbpubk \
		--bmpfv="${bmp_dir}/bmpblk.bin" \
		gbb.bin ||
		die "Failed to write keys and HWID to the GBB."

	#
	# Sign the bootstub.  This is a combination of the board specific
	# BCT and the stub U-Boot image.  The cbootimage tool takes a config
	# file and an output filename to write to.
	#
	cbootimage boot.cfg bootstub.bin ||
		die "Failed to sign boot stub image."

	pack_firmware_image layout.py \
		KEYDIR=${keys}/ \
		BOOTSTUB_IMAGE=bootstub.bin \
		RECOVERY_IMAGE=${recovery_image} \
		GBB_IMAGE=gbb.bin \
		FIRMWARE_A_IMAGE=${normal_image} \
		FIRMWARE_B_IMAGE=${normal_image} \
		OUTPUT=image.bin ||
		die "Failed to pack the firmware image."
}

src_install() {
	insinto /u-boot
	doins boot.cfg || die
	doins layout.py || die
	doins image.bin || die
	doins bootstub.bin || die
}

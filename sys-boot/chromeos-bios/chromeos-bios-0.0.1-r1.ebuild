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
DEPEND="virtual/u-boot
	chromeos-base/vboot_reference
	"

keys="${ROOT}/usr/share/vboot/devkeys"
autoconf="${ROOT}/u-boot/autoconf.mk"
stub_image="${ROOT}/u-boot/u-boot.bin"
recovery_image="${ROOT}/u-boot/u-boot.bin"
normal_image="${ROOT}/u-boot/u-boot.bin"

get_hwid() {
	grep -m1 CONFIG_CHROMEOS_HWID ${autoconf} | tr -d "\"" | cut -d = -f 2
	assert
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

src_compile() {
	construct_layout > layout.py

	gbb_utility -c 0x100,0x1000,0x03de80,0x1000 gbb.bin ||
		die "Failed to create the GBB."

	gbb_utility -s \
		--hwid="$(get_hwid)" \
		--rootkey=${keys}/root_key.vbpubk \
		--recoverykey=${keys}/recovery_key.vbpubk \
		gbb.bin ||
		die "Failed to write keys and HWID to the GBB."

	pack_firmware_image layout.py \
		KEYDIR=${keys}/ \
		BOOTSTUB_IMAGE=${stub_image} \
		RECOVERY_IMAGE=${recovery_image} \
		GBB_IMAGE=gbb.bin \
		FIRMWARE_A_IMAGE=${normal_image} \
		FIRMWARE_B_IMAGE=${normal_image} \
		OUTPUT=image.bin ||
		die "Failed to pack the firmware image."
}

src_install() {
	insinto /u-boot
	doins image.bin || die
}

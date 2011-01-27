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

layout="${ROOT}/u-boot/firmware_layout.cfg"
keys="${ROOT}/usr/share/vboot/devkeys"

get_hwid() {
	grep -m1 CONFIG_CHROMEOS_HWID ${layout} | tr -d "\"" | cut -d = -f 2
	assert
}

src_compile() {
	gbb_utility -c 0x100,0x1000,0x03de80,0x1000 \
		gbb.bin || die "Failed to create the GBB"

	gbb_utility -s \
		--hwid="$(get_hwid)" \
		--rootkey=${keys}/root_key.vbpubk \
		--recoverykey=${keys}/recovery_key.vbpubk \
		gbb.bin || die "Failed to write keys and HWID to the GBB"

	pack_firmware_image ${layout} \
		KEYDIR=${keys}/ \
		BOOTSTUB_IMAGE=${ROOT}/u-boot/u-boot.bin \
		RECOVERY_IMAGE=${ROOT}/u-boot/u-boot.bin \
		GBB_IMAGE=gbb.bin \
		FIRMWARE_A_IMAGE=${ROOT}/u-boot/u-boot.bin \
		FIRMWARE_B_IMAGE=${ROOT}/u-boot/u-boot.bin \
		OUTPUT=image.bin || die "Failed to pack the firmware image"
}

src_install() {
	insinto /u-boot
	doins image.bin || die
}

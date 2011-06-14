# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit cros-arm-firmware-image

DESCRIPTION="ChromeOS BIOS builder"
HOMEPAGE="http://www.chromium.org"
LICENSE=""
SLOT="0"
KEYWORDS="arm"
IUSE=""

DEPEND="virtual/tegra-bct
	virtual/u-boot
	chromeos-base/vboot_reference"

RDEPEND="${DEPEND}
	sys-apps/flashrom"

src_compile() {
	construct_layout
	create_gbb

	# TODO(clchiou): obsolete recovery_image.bin
	create_image
	create_image "legacy_" ${CROS_ARM_FIRMWARE_IMAGE_LEGACY_IMAGE}
	create_image "recovery_" ${CROS_ARM_FIRMWARE_IMAGE_RECOVERY_IMAGE}
}

src_install() {
	local prefix

	insinto /u-boot
	doins ${CROS_ARM_FIRMWARE_IMAGE_LAYOUT} || die

	# TODO(clchiou): obsolete recovery_image.bin
	for prefix in "" "legacy_" "recovery_"; do
		doins "${prefix}image.bin" || die
		doins "${prefix}bootstub.bin" || die
	done

	exeinto /u-boot
	doexe ${FILESDIR}/clobber_firmware || die
}

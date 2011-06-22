# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit cros-arm-firmware-image

DESCRIPTION="ChromeOS arm firmware image builder"
HOMEPAGE="http://www.chromium.org"
LICENSE=""
SLOT="0"
KEYWORDS="arm"
IUSE=""

# TODO(clchiou): pack and install legacy_image.bin when chromeos-u-boot-next
# generates a legacy u-boot image.

# TODO(clchiou): this is specifically depended on u-boot-next for now, which
# implements onestop firmware; this will depend on virtual/u-boot in the future
DEPEND="virtual/tegra-bct
	sys-boot/chromeos-u-boot-next
	chromeos-base/vboot_reference"

RDEPEND="${DEPEND}
	sys-apps/flashrom"

CROS_ARM_FIRMWARE_IMAGE_SYSTEM_MAP="${ROOT%/}/u-boot/System.map"
CROS_ARM_FIRMWARE_IMAGE_AUTOCONF="${ROOT%/}/u-boot/autoconf.mk"

CROS_ARM_FIRMWARE_IMAGE_STUB_IMAGE="${ROOT%/}/u-boot/u-boot.bin"
CROS_ARM_FIRMWARE_IMAGE_RECOVERY_IMAGE=zero.bin
CROS_ARM_FIRMWARE_IMAGE_DEVELOPER_IMAGE=zero.bin
CROS_ARM_FIRMWARE_IMAGE_NORMAL_IMAGE=zero.bin

src_compile() {
	dd if=/dev/zero of=zero.bin count=1
	construct_layout
	create_gbb
	create_image
}

src_install() {
	insinto /u-boot
	doins image.bin || die
}

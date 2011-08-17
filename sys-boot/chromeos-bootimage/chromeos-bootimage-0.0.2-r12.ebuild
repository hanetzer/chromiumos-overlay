# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit cros-debug

DESCRIPTION="ChromeOS arm firmware image builder"
HOMEPAGE="http://www.chromium.org"
LICENSE=""
SLOT="0"
KEYWORDS="arm x86"
IUSE=""

# TODO(dianders) Eventually we'll have virtual/chromeos-bootimage.
# When that happens the various implementations (like
# sys-boot/chromeos-bootimage-seaboard) will do the depending on
# sys-boot/tegra2-public-firmware-fdts.  For now we'll hardcode it.
DEPEND="
	!sys-boot/chromeos-bios
	arm? (
			virtual/tegra-bct
			virtual/u-boot
			sys-boot/tegra2-public-firmware-fdts
	     )
	x86? (
			sys-boot/chromeos-coreboot
			sys-boot/x86-firmware-fdts
		 )
	chromeos-base/vboot_reference
	"

RDEPEND="${DEPEND}
	sys-apps/flashrom"

# TODO(clchiou): Here are the action items for fixing x86 build that I can
# think of:
# * Unify the install directories (/u-boot and /coreboot) to one (probably
#   places like /firmware or /lib/firmware?)
# * Make BCT optional to cros_bundle_firmware because it is specific to ARM
# * Make sure there is an x86 dtb installed

# Directory where the generated files are looked for and placed.
if use x86; then
	CROS_FIRMWARE_IMAGE_DIR="/coreboot"
else
	CROS_FIRMWARE_IMAGE_DIR="/u-boot"
fi

# Location of the board-specific bct file
CROS_FIRMWARE_BCT="${ROOT%/}${CROS_FIRMWARE_IMAGE_DIR}/bct/board.bct"

# Location of the u-boot flat device tree binary blob (FDT)
# TODO(dianders): remove looking at PKG_CONFIG once
# virtual/chromeos-bootimage is complete.
CROS_FIRMWARE_DTB="$(echo "${PKG_CONFIG#pkg-config-}.dtb" | tr _ '-')"
CROS_FIRMWARE_DTB="${ROOT%/}${CROS_FIRMWARE_IMAGE_DIR}/dtb/${CROS_FIRMWARE_DTB}"

# We only have a single U-Boot, and it is called u-boot.bin
CROS_FIRMWARE_IMAGE="${ROOT%/}${CROS_FIRMWARE_IMAGE_DIR}/u-boot.bin"

# Location of the devkeys
CROS_FIRMWARE_DEVKEYS="${ROOT%/}/usr/share/vboot/devkeys"

# The real bmpblk must be verified and installed by HWID matchin in factory
# process. Default one should be a pre-genereated blob.
CROS_FIRMWARE_BMPBLK="${FILESDIR}/default.bmpblk"

src_compile() {
	local SECURE_FLAGS=''
	local COMMON_FLAGS=''
	if ! use cros-debug; then
		SECURE_FLAGS+=' --add-config-int silent_console 1'
	fi
	if use x86; then
		COMMON_FLAGS+=" --coreboot \
			${ROOT%/}${CROS_FIRMWARE_IMAGE_DIR}/coreboot.rom"
	fi

	cros_bundle_firmware \
		${COMMON_FLAGS} \
		--bct "${CROS_FIRMWARE_BCT}" \
		--uboot "${CROS_FIRMWARE_IMAGE}" \
		--dt "${CROS_FIRMWARE_DTB}" \
		--key "${CROS_FIRMWARE_DEVKEYS}" \
		--bmpblk "${CROS_FIRMWARE_BMPBLK}" \
		--bootcmd "vboot_twostop" \
		--bootsecure \
		${SECURE_FLAGS} \
		--outdir normal \
		--output image.bin ||
	die "failed to build image."

	# make legacy image
	cros_bundle_firmware \
		${COMMON_FLAGS} \
		--bct "${CROS_FIRMWARE_BCT}" \
		--uboot "${CROS_FIRMWARE_IMAGE}" \
		--dt "${CROS_FIRMWARE_DTB}" \
		--key "${CROS_FIRMWARE_DEVKEYS}" \
		--bmpblk "${CROS_FIRMWARE_BMPBLK}" \
		--add-config-int load_env 1 \
		--outdir legacy \
		--output legacy_image.bin ||
	die "failed to build legacy image."
}

src_install() {
	insinto "${CROS_FIRMWARE_IMAGE_DIR}"
	doins image.bin || die
	doins legacy_image.bin || die
}

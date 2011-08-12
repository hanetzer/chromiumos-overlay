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
	arm? (
			!sys-boot/chromeos-bios
			virtual/tegra-bct
			virtual/u-boot
			sys-boot/tegra2-public-firmware-fdts
	     )
	x86? ( sys-boot/chromeos-coreboot )
	chromeos-base/vboot_reference
	"

RDEPEND="${DEPEND}
	sys-apps/flashrom"


# Directory where the generated files are looked for and placed.
CROS_FIRMWARE_IMAGE_DIR=${ROOT%/}/u-boot

# Location of the board-specific bct file
CROS_FIRMWARE_IMAGE_BCT=${CROS_FIRMWARE_IMAGE_DIR}/bct/board.bct

# Location of the devkeys
CROS_FIRMWARE_IMAGE_DEVKEYS=${ROOT%/}/usr/share/vboot/devkeys

# Location of the u-boot flat device tree binary blob (FDT)
CROS_FIRMWARE_DTB=

if use x86; then
	DST_DIR='/coreboot'
	CROS_FIRMWARE_IMAGE_DIR="${ROOT}${DST_DIR}"
else
	# TODO(dianders): remove looking at PKG_CONFIG once
	# virtual/chromeos-bootimage is complete.
	DST_DIR='/u-boot'
	CROS_FIRMWARE_DTB=$(echo "${PKG_CONFIG#pkg-config-}.dtb" | tr _ '-')
	CROS_FIRMWARE_DTB="${CROS_FIRMWARE_IMAGE_DIR}/dtb/${CROS_FIRMWARE_DTB}"
fi

# We only have a single U-Boot, and it is called u-boot.bin
# TODO(sjg): simplify the eclass when we deprecate the old U-Boot
CROS_FIRMWARE_IMAGE_STUB_IMAGE="${ROOT%/}/u-boot/u-boot.bin"

# The real bmpblk must be verified and installed by HWID matchin in factory
# process. Default one should be a pre-genereated blob.
CROS_FIRMWARE_IMAGE_BMPBLK="${FILESDIR}/default.bmpblk"

src_compile() {
	# TODO(clchiou) fix x86 build later
	if use x86; then
		touch image.bin
		return
	fi

	BUNDLE_FLAGS=''
	if ! use cros-debug; then
		BUNDLE_FLAGS+=' --add-config-int silent_console 1'
	fi

	cros_bundle_firmware \
		--bct "${CROS_FIRMWARE_IMAGE_BCT}" \
		--uboot "${CROS_FIRMWARE_IMAGE_STUB_IMAGE}" \
		--dt "${CROS_FIRMWARE_DTB}" \
		--key "${CROS_FIRMWARE_IMAGE_DEVKEYS}" \
		--bmpblk "${CROS_FIRMWARE_IMAGE_BMPBLK}" \
		--bootcmd "vboot_twostop" \
		--bootsecure \
		${BUNDLE_FLAGS} \
		--outdir normal \
		--output image.bin ||
	die "failed to build image."

	# make legacy image
	if use arm && [ -n "${CROS_FIRMWARE_DTB}" ]; then
		cros_bundle_firmware \
			--bct "${CROS_FIRMWARE_IMAGE_BCT}" \
                        --uboot "${CROS_FIRMWARE_IMAGE_STUB_IMAGE}" \
			--dt "${CROS_FIRMWARE_DTB}" \
			--key "${CROS_FIRMWARE_IMAGE_DEVKEYS}" \
			--bmpblk "${CROS_FIRMWARE_IMAGE_BMPBLK}" \
			--add-config-int load_env 1 \
			--outdir legacy \
			--output legacy_image.bin ||
		die "failed to build legacy image."
	fi
}

src_install() {
	insinto "${DST_DIR}"
	doins image.bin || die
	if use arm && [ -n "${CROS_FIRMWARE_DTB}" ]; then
		doins legacy_image.bin || die
	fi
}

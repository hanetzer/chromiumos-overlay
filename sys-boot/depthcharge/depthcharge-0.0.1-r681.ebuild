# Copyright 2012 The Chromium OS Authors.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT=("d7a146817838ee608d5e42c8df7d7d291bc366df" "e8117120b677937902fc3c75ba3cee97e1fa0dc1")
CROS_WORKON_TREE=("ff665814ea0eef21eaaaca24b892d7f9fcd95fda" "64d60fe5825ea24dd2260722f923b6d1620af58d")
CROS_WORKON_PROJECT=("chromiumos/platform/depthcharge" "chromiumos/platform/vboot_reference")

DESCRIPTION="coreboot's depthcharge payload"
HOMEPAGE="http://www.coreboot.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="mocktpm"

X86_DEPEND="
	sys-apps/coreboot-utils
	"
RDEPEND="
	sys-boot/libpayload
	x86? ( ${X86_DEPEND} )
	amd64? ( ${X86_DEPEND} )
	chromeos-base/vboot_reference
	"
DEPEND=${RDEPEND}

CROS_WORKON_LOCALNAME=("../platform/depthcharge" "../platform/vboot_reference")
VBOOT_REFERENCE_DESTDIR="${S}/vboot_reference"
CROS_WORKON_DESTDIR=("${S}" "${VBOOT_REFERENCE_DESTDIR}")

inherit cros-workon cros-board toolchain-funcs

src_configure() {
	cros-workon_src_configure
}

src_compile() {
	local board=$(get_current_board_with_variant)
	tc-getCC

	# Firmware related binaries are compiled with a 32-bit toolchain
	# on 64-bit platforms
	if use amd64 ; then
		export CROSS_COMPILE="i686-pc-linux-gnu-"
		export CC="${CROSS_COMPILE}gcc"
	else
		export CROSS_COMPILE=${CHOST}-
	fi

	if use mocktpm ; then
		export MOCK_TPM=1
	fi

	emake distclean
	emake defconfig \
		LIBPAYLOAD_DIR="${ROOT}/firmware/libpayload/" \
		BOARD="${board}" \
		|| die "depthcharge make defconfig failed"
	emake \
		LIBPAYLOAD_DIR="${ROOT}/firmware/libpayload/" \
		VB_SOURCE="${VBOOT_REFERENCE_DESTDIR}" \
		|| die "depthcharge build failed"
}

src_install() {
	local build_root="build"
	local destdir="/firmware/depthcharge"
	local dtsdir="/firmware/dts"
	local board=$(get_current_board_with_variant)
	local files_to_copy=(
		depthcharge.elf{,.map}
		depthcharge.{ro,rw}.{bin,elf{,.map}}
		netboot.{bin,elf{,.map}}
	)

	insinto "${dtsdir}"
	doins "board/${board}/fmap.dts"

	cd "${build_root}"
	insinto "${destdir}"
	doins "${files_to_copy[@]}"

	# Install the depthcharge.payload file into the firmware
	# directory for downstream use if it is produced.
	if [[ -r depthcharge.payload ]]; then
		doins {depthcharge,netboot}.payload
	fi
}

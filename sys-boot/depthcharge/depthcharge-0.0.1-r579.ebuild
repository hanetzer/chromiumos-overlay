# Copyright 2012 The Chromium OS Authors.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT=("69bd775003fc65bb6f30d8804847373a865e5e70" "d96b25d0c0a739d351b8f09b128782ca12b7b0e1")
CROS_WORKON_TREE=("aa25d0be876397b3af62f489adb13f574cc99c9f" "d21304a370be6a2553037256d28cc5983b86d37c")
CROS_WORKON_PROJECT=("chromiumos/platform/depthcharge" "chromiumos/platform/vboot_reference")

DESCRIPTION="coreboot's depthcharge payload"
HOMEPAGE="http://www.coreboot.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"
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

	insinto "${destdir}"
	doins "${build_root}"/depthcharge.elf
	doins "${build_root}"/depthcharge.ro.elf
	doins "${build_root}"/depthcharge.ro.bin
	doins "${build_root}"/depthcharge.rw.elf
	doins "${build_root}"/depthcharge.rw.bin
	doins "${build_root}"/netboot.elf
	doins "${build_root}"/netboot.bin

	# Install the depthcharge.payload file into the firmware
	# directory for downstream use if it is produced.
	if [[ -r "${build_root}"/depthcharge.payload ]]; then
		doins "${build_root}"/depthcharge.payload
		doins "${build_root}"/netboot.payload
	fi

	insinto "${dtsdir}"
	doins "board/${board}/fmap.dts"
}

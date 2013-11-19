# Copyright 2012 The Chromium OS Authors.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT=("7c3dab264079e7f5956b294377dabf26d52efd3c" "a3d70a3d2b5c052db039d097aaffa42008da24b5")
CROS_WORKON_TREE=("e56b7c1c91a62164040227390ea2b07791f18398" "40263855d5eef64cea1c729e89397d0f4cef4880")
CROS_WORKON_PROJECT=("chromiumos/platform/depthcharge" "chromiumos/platform/vboot_reference")

DESCRIPTION="coreboot's depthcharge payload"
HOMEPAGE="http://www.coreboot.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"
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

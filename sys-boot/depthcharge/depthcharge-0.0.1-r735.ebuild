# Copyright 2012 The Chromium OS Authors.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT=("4621da93a3212fce0c15491944707bae6789cb30" "850b74fa19f6eadd1d3221f484c738f41f993653")
CROS_WORKON_TREE=("e7e87d2b3810236af5915d1f4c490effc0a70a30" "37351c34a77079000d5daa458779f1dfbff577c2")
CROS_WORKON_PROJECT=(
	"chromiumos/platform/depthcharge"
	"chromiumos/platform/vboot_reference"
)

DESCRIPTION="coreboot's depthcharge payload"
HOMEPAGE="http://www.coreboot.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="mocktpm fwconsole"

RDEPEND="
	sys-apps/coreboot-utils
	sys-boot/libpayload
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
		echo "CONFIG_MOCK_TPM=y" >> "board/${board}/defconfig"
	fi
	if use fwconsole ; then
		echo "CONFIG_CLI=y" >> "board/${board}/defconfig"
		echo "CONFIG_SYS_PROMPT=\"${board}: \"" >>  \
		  "board/${board}/defconfig"
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

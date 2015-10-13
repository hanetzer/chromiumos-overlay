# Copyright 2012 The Chromium OS Authors.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT=("996ba8f31379a7201e63c7dcdfaec6d2687217d8" "12a55f255aaea2f12362e4f832a0bd48eb29f5dd")
CROS_WORKON_TREE=("5698bfe85dfbf7402ea72049e1349ede6011e736" "f235ebf2cd846c852371a96cf76e3282ff0c26be")
CROS_WORKON_PROJECT=(
	"chromiumos/platform/depthcharge"
	"chromiumos/platform/vboot_reference"
)

DESCRIPTION="coreboot's depthcharge payload"
HOMEPAGE="http://www.coreboot.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="fastboot fwconsole mocktpm pd_sync unified_depthcharge"

RDEPEND="
	sys-apps/coreboot-utils
	sys-boot/libpayload
	chromeos-base/vboot_reference
	"
DEPEND=${RDEPEND}

CROS_WORKON_LOCALNAME=("../platform/depthcharge" "../platform/vboot_reference")
VBOOT_REFERENCE_DESTDIR="${S}/vboot_reference"
CROS_WORKON_DESTDIR=("${S}" "${VBOOT_REFERENCE_DESTDIR}")

# Don't strip to ease remote GDB use (cbfstool strips final binaries anyway)
STRIP_MASK="*"

inherit cros-workon cros-board toolchain-funcs

src_configure() {
	cros-workon_src_configure
}

src_compile() {
	local board=$(get_current_board_with_variant)
	if [[ ! -d "board/${board}" ]]; then
		board=$(get_current_board_no_variant)
	fi

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
	emake defconfig BOARD="${board}"
	emake dts BOARD="${board}"

	if use unified_depthcharge; then
		emake depthcharge_unified VB_SOURCE="${VBOOT_REFERENCE_DESTDIR}" \
		          PD_SYNC=$(usev pd_sync) \
			  LIBPAYLOAD_DIR="${SYSROOT}/firmware/libpayload/"
		emake dev_unified VB_SOURCE="${VBOOT_REFERENCE_DESTDIR}" \
		          PD_SYNC=$(usev pd_sync) \
			  LIBPAYLOAD_DIR="${SYSROOT}/firmware/libpayload_gdb/"
	else
		emake depthcharge_ro_rw VB_SOURCE="${VBOOT_REFERENCE_DESTDIR}" \
		          PD_SYNC=$(usev pd_sync) \
			  LIBPAYLOAD_DIR="${SYSROOT}/firmware/libpayload/"
		emake dev_ro_rw VB_SOURCE="${VBOOT_REFERENCE_DESTDIR}" \
		          PD_SYNC=$(usev pd_sync) \
			  LIBPAYLOAD_DIR="${SYSROOT}/firmware/libpayload_gdb/"
	fi

	emake netboot_unified VB_SOURCE="${VBOOT_REFERENCE_DESTDIR}" \
	          PD_SYNC=$(usev pd_sync) \
		  LIBPAYLOAD_DIR="${SYSROOT}/firmware/libpayload_gdb/"

	if use fastboot; then
		echo "CONFIG_FASTBOOT_MODE=y" >> "board/${board}/defconfig"
		emake defconfig BOARD="${board}"

		emake fastboot_unified VB_SOURCE="${VBOOT_REFERENCE_DESTDIR}" \
			  PD_SYNC=$(usev pd_sync) \
			  LIBPAYLOAD_DIR="${SYSROOT}/firmware/libpayload/"
	fi
}

src_install() {
	local dstdir="/firmware"
	local board=$(get_current_board_with_variant)
	if [[ ! -d "board/${board}" ]]; then
		board=$(get_current_board_no_variant)
	fi

	insinto "${dstdir}"
	newins .config depthcharge.config

	pushd "build" >/dev/null || die "couldn't access build/ directory"

	insinto "${dstdir}/dts"
	doins "fmap.dts"

	local files_to_copy=(netboot.{bin,elf{,.map},payload})
	if use unified_depthcharge ; then
		files_to_copy+=({depthcharge,dev}.{elf{,.map},payload})
	else
		files_to_copy+=({depthcharge,dev}.{ro,rw}.{bin,elf{,.map}})
	fi

	if use fastboot ; then
		files_to_copy+=(fastboot.{bin,elf{,.map},payload})
	fi

	insinto "${dstdir}/depthcharge"
	doins "${files_to_copy[@]}"

	popd >/dev/null
}

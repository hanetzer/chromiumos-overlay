# Copyright 2012 The Chromium OS Authors.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_PROJECT=(
	"chromiumos/platform/depthcharge"
	"chromiumos/platform/vboot_reference"
)

DESCRIPTION="coreboot's depthcharge payload"
HOMEPAGE="http://www.coreboot.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~*"
IUSE="detachable_ui fastboot fwconsole mocktpm pd_sync"

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

# Get the depthcharge board config to build for.
# Checks the current board with/without variant. Echoes the board config file
# that should be used to build depthcharge.
get_board() {
	local board=$(get_current_board_with_variant)
	if [[ ! -d "board/${board}" ]]; then
		board=$(get_current_board_no_variant)
	fi

	echo "${board}"
}

src_compile() {
	local board="$(get_board)"

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
	if use detachable_ui ; then
		echo "CONFIG_DETACHABLE_UI=y" >> "board/${board}/defconfig"
	fi

	[[ ${PV} == "9999" ]] && emake distclean
	emake defconfig BOARD="${board}"

	emake depthcharge VB_SOURCE="${VBOOT_REFERENCE_DESTDIR}" \
			  PD_SYNC=$(usev pd_sync) \
		  LIBPAYLOAD_DIR="${SYSROOT}/firmware/libpayload/"
	emake dev VB_SOURCE="${VBOOT_REFERENCE_DESTDIR}" \
			  PD_SYNC=$(usev pd_sync) \
		  LIBPAYLOAD_DIR="${SYSROOT}/firmware/libpayload_gdb/"

	emake netboot VB_SOURCE="${VBOOT_REFERENCE_DESTDIR}" \
	          PD_SYNC=$(usev pd_sync) \
		  LIBPAYLOAD_DIR="${SYSROOT}/firmware/libpayload_gdb/"

	if use fastboot; then
		emake fastboot VB_SOURCE="${VBOOT_REFERENCE_DESTDIR}" \
			  PD_SYNC=$(usev pd_sync) \
			  LIBPAYLOAD_DIR="${SYSROOT}/firmware/libpayload/"
	fi
}

src_install() {
	local dstdir="/firmware"
	local board="$(get_board)"

	insinto "${dstdir}"
	newins .config depthcharge.config

	pushd "build" >/dev/null || die "couldn't access build/ directory"

	local files_to_copy=({netboot,depthcharge,dev}.elf{,.map})

	if use fastboot ; then
		files_to_copy+=(fastboot.elf{,.map})
	fi

	insinto "${dstdir}/depthcharge"
	doins "${files_to_copy[@]}"

	popd >/dev/null
}

# Copyright 2012 The Chromium OS Authors.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT=("4513fac4ef06859b69bf2fa13c6c05556c558f76" "f3101060309281da2095744ca77a84e3d9703755")
CROS_WORKON_TREE=("b317150d716bdc69c26d631d591523972ee16e07" "0c4853fc7c9a8680b2ca58aa3d44006998478d32")
CROS_WORKON_PROJECT=(
	"chromiumos/platform/depthcharge"
	"chromiumos/platform/vboot_reference"
)

DESCRIPTION="coreboot's depthcharge payload"
HOMEPAGE="http://www.coreboot.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
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

# Build depthcharge with common options.
# Usage example: dc_make dev LIBPAYLOAD_DIR="libpayload"
# Args:
#   $1: Target to build
#   $2: Build directory to use.
#   $3: Firmware file to use for LIBPAYLOAD_DIR
#   $4+: Any other Makefile arguments.
dc_make() {
	local target="$1"
	local builddir="$2"
	local libpayload

	[[ -n "$3" ]] && libpayload="LIBPAYLOAD_DIR=${SYSROOT}/firmware/$3/"

	shift 3
	emake VB_SOURCE="${VBOOT_REFERENCE_DESTDIR}" \
		PD_SYNC=$(usev pd_sync) \
		obj="${builddir}" \
		${libpayload} \
		"${target}" \
		"$@"
}

src_compile() {
	local board="$(get_board)"
	local builddir="build"

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

	[[ ${PV} == "9999" ]] && dc_make distclean "${builddir}" ""
	dc_make defconfig "${builddir}" "" BOARD="${board}"

	dc_make depthcharge "${builddir}" libpayload
	dc_make dev "${builddir}" libpayload_gdb
	dc_make netboot "${builddir}" libpayload_gdb

	if use fastboot; then
		dc_make fastboot "${builddir}" libpayload
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

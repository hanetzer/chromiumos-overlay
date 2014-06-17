# Copyright 2012 The Chromium OS Authors.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT=("cfcdafbb67286729c2b7462a6290f6f33c1d97af" "aa888463b860c2852f3fcb17baf8de395fcca294")
CROS_WORKON_TREE=("9054d02cc5739a8aa59d97c250cb2a0c2a7af88a" "329c599101e97cffb3c59f2d30ec8064be252b68")
CROS_WORKON_PROJECT=(
	"chromiumos/platform/depthcharge"
	"chromiumos/platform/vboot_reference"
)

DESCRIPTION="coreboot's depthcharge payload"
HOMEPAGE="http://www.coreboot.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="mocktpm fwconsole unified_depthcharge"

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

make_depthcharge() {
	local suffix="$1"
	local broot="${S}/build${suffix}"

	emake obj="${broot}" distclean
	emake obj="${broot}" defconfig BOARD="${board}"
	emake obj=${broot} \
		LIBPAYLOAD_DIR="${SYSROOT}/firmware/libpayload${suffix}/" \
		VB_SOURCE="${VBOOT_REFERENCE_DESTDIR}"
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

	make_depthcharge ""
	make_depthcharge "_gdb"
}

install_depthcharge() {
	local suffix="$1"
	local build_root="build${suffix}"
	local destdir="/firmware/depthcharge${suffix}"
	pushd "${build_root}" || die "couldn't access ${build_root}"

	local files_to_copy=(netboot.{bin,elf{,.map}})
	if use unified_depthcharge ; then
		files_to_copy+=(depthcharge.elf{,.map})
	else
		files_to_copy+=(depthcharge.{ro,rw}.{bin,elf{,.map}})
	fi

	insinto "${destdir}"
	doins "${files_to_copy[@]}"

	# Install the depthcharge.payload file into the firmware
	# directory for downstream use if it is produced.
	if [[ -r depthcharge.payload ]]; then
		doins {depthcharge,netboot}.payload
	fi

	popd
}

src_install() {
	local dtsdir="/firmware/dts"
	local board=$(get_current_board_with_variant)
	if [[ ! -d "board/${board}" ]]; then
		board=$(get_current_board_no_variant)
	fi

	insinto "${dtsdir}"
	doins "board/${board}/fmap.dts"

	install_depthcharge ""
	install_depthcharge "_gdb"
}

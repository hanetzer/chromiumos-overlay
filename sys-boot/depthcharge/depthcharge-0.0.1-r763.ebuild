# Copyright 2012 The Chromium OS Authors.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT=("43d794d3c3f8226888e7b59d650e9654dae5bea3" "bdc2c943432d795e8cffd268fa52bc4b2d9ef153")
CROS_WORKON_TREE=("270fcfee736d653615653dc71de7fe11a754bcb6" "1a00223c2e129cb03e0ea454d81859f718429efc")
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

# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=6

CROS_WORKON_PROJECT=("chromiumos/third_party/u-boot" "chromiumos/platform/vboot_reference")
CROS_WORKON_LOCALNAME=("u-boot/files" "../platform/vboot_reference")
VBOOT_REFERENCE_DESTDIR="${S}/vboot_reference"
CROS_WORKON_DESTDIR=("${S}" "${VBOOT_REFERENCE_DESTDIR}")

inherit toolchain-funcs flag-o-matic cros-workon

DESCRIPTION="Das U-Boot boot loader"
HOMEPAGE="http://www.denx.de/wiki/U-Boot"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~*"
IUSE="vboot"

DEPEND=""

RDEPEND="${DEPEND}
	chromeos-base/u-boot-scripts
	"

UB_BUILD_DIR="build"

# @FUNCTION: get_current_u_boot_config
# @DESCRIPTION:
# Finds the config for the current board by checking the master configuration.
get_current_u_boot_config() {
	cros_config_host get-firmware-build-targets u-boot || die
}

umake() {
	# Add `ARCH=` to reset ARCH env and let U-Boot choose it.
	ARCH= emake "${COMMON_MAKE_FLAGS[@]}" "$@"
}

src_configure() {
	export LDFLAGS=$(raw-ldflags)
	tc-export BUILD_CC

	config="$(get_current_u_boot_config)"
	[[ -n "${config}" ]] || die "No U-Boot config selected"
	elog "Using U-Boot config: ${config}"

	# Firmware related binaries are compiled with 32-bit toolchain
	# on 64-bit platforms
	if [[ ${CHOST} == x86_64-* ]]; then
		CROSS_PREFIX="i686-pc-linux-gnu-"
	else
		CROSS_PREFIX="${CHOST}-"
	fi

	COMMON_MAKE_FLAGS=(
		"CROSS_COMPILE=${CROSS_PREFIX}"
		DEV_TREE_SEPARATE=1
		"HOSTCC=${BUILD_CC}"
		HOSTSTRIP=true
		QEMU_ARCH=
		WERROR=y
	)
	if use vboot; then
		COMMON_MAKE_FLAGS+=(
			USE_STDINT=1
			"VBOOT_SOURCE=${VBOOT_REFERENCE_DESTDIR}"
			VBOOT_DEBUG=1
		)
	fi
	if use dev; then
		# Avoid hiding the errors and warnings
		COMMON_MAKE_FLAGS+=(
			-s
			QUIET=1
		)
	else
		COMMON_MAKE_FLAGS+=(
			-k
		)
	fi

	BUILD_FLAGS=(
		"O=${UB_BUILD_DIR}"
	)

	umake "${BUILD_FLAGS[@]}" distclean
	umake "${BUILD_FLAGS[@]}" "${config}_defconfig"
}

src_compile() {
	umake "${BUILD_FLAGS[@]}" all
}

src_install() {
	local inst_dir="/firmware"
	local files_to_copy=(
		System.map
		u-boot
		u-boot.bin
		u-boot.img
	)
	local f

	insinto "${inst_dir}"

	for f in "${files_to_copy[@]}"; do
		[[ -f "${UB_BUILD_DIR}/${f}" ]] &&
			doins "${f/#/${UB_BUILD_DIR}/}"
	done

	insinto "${inst_dir}/dtb"
	doins "${UB_BUILD_DIR}/dts/"*.dtb
}

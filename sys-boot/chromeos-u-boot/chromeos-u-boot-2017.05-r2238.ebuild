# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT=("1e26ac220258662e911d2471a090c9219566fffe" "392211f0358919d510179ad399d8f056180e652e")
CROS_WORKON_TREE=("53c6615d5ff3a2a77a437c91d553ec3b4058a255" "3326672902a056c1b70520574aa14724a550dfdd")
CROS_WORKON_PROJECT=("chromiumos/third_party/u-boot" "chromiumos/platform/vboot_reference")
CROS_WORKON_LOCALNAME=("u-boot/files" "../platform/vboot_reference")
VBOOT_REFERENCE_DESTDIR="${S}/vboot_reference"
CROS_WORKON_DESTDIR=("${S}" "${VBOOT_REFERENCE_DESTDIR}")

inherit toolchain-funcs flag-o-matic cros-workon

DESCRIPTION="Das U-Boot boot loader"
HOMEPAGE="http://www.denx.de/wiki/U-Boot"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="dev u_boot_netboot profiling"

DEPEND="!sys-boot/x86-firmware-fdts
	chromeos-base/chromeos-config-host
	"

RDEPEND="${DEPEND}
	chromeos-base/u-boot-scripts
	"

UB_BUILD_DIR="${WORKDIR}/build"
UB_BUILD_DIR_NB="${UB_BUILD_DIR%/}_nb"
UB_BUILD_DIR_RO="${UB_BUILD_DIR%/}_ro"

# @FUNCTION: get_current_u_boot_config
# @DESCRIPTION:
# Finds the config for the current board by checking the master configuration.
get_current_u_boot_config() {
	cros_config_host get-firmware-build-targets u-boot || die
}

# @FUNCTION: get_config_var
# @USAGE: <config name> <requested variable>
# @DESCRIPTION:
# Returns the value of the requested variable in the specified config
# if present. This can only be called after make config.
get_config_var() {
	local config="${1%_config}"
	local var="${2}"
	local boards_cfg="${S}/boards.cfg"
	local i
	case "${var}" in
	ARCH)	i=2;;
	CPU)	i=3;;
	BOARD)	i=4;;
	VENDOR)	i=5;;
	SOC)	i=6;;
	*)	die "Unsupported field: ${var}"
	esac
	awk -v i=$i -v cfg="${config}" '$1 == cfg { print $i }' "${boards_cfg}"
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
		"VBOOT_SOURCE=${VBOOT_REFERENCE_DESTDIR}"
		DEV_TREE_SEPARATE=1
		"HOSTCC=${BUILD_CC}"
		HOSTSTRIP=true
		USE_STDINT=1
		VBOOT_DEBUG=1
		QEMU_ARCH=
		WERROR=y
	)
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

	if use profiling; then
		COMMON_MAKE_FLAGS+=( VBOOT_PERFORMANCE=1 )
	fi

	BUILD_FLAGS=(
		"O=${UB_BUILD_DIR}"
	)

	umake "${BUILD_FLAGS[@]}" distclean
	umake "${BUILD_FLAGS[@]}" "${config}_defconfig"

	if use u_boot_netboot; then
		BUILD_NB_FLAGS=(
			"O=${UB_BUILD_DIR_NB}"
			BUILD_FACTORY_IMAGE=1
		)
		umake "${BUILD_NB_FLAGS[@]}" distclean
		umake "${BUILD_NB_FLAGS[@]}" "${config}_defconfig"
	fi
}

src_compile() {
	umake "${BUILD_FLAGS[@]}" all

	if use u_boot_netboot; then
		umake "${BUILD_NB_FLAGS[@]}" all
	fi
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

	if use u_boot_netboot; then
		newins "${UB_BUILD_DIR_NB}/u-boot.bin" u-boot_netboot.bin
	fi

	insinto "${inst_dir}/dtb"
	doins "${UB_BUILD_DIR}/dts/"*.dtb
}

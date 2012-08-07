# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT=0c64edf70ff88bd5c32d67df87eb3e30c0d8988c
CROS_WORKON_TREE="a765d900f4943012112055e4519ecfe79b002b85"

EAPI=4
CROS_WORKON_PROJECT="chromiumos/third_party/u-boot"

# TODO(sjg): Remove cros-board as it violates the idea of having no specific
# board knowledge in the build system. At present it is only needed for the
# netboot hack.
inherit cros-debug toolchain-funcs cros-board flag-o-matic

DESCRIPTION="Das U-Boot boot loader"
HOMEPAGE="http://www.denx.de/wiki/U-Boot"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="dev profiling factory-mode"

DEPEND=">=chromeos-base/vboot_reference-firmware-0.0.1-r175
	!sys-boot/x86-firmware-fdts
	!sys-boot/exynos-u-boot
	!sys-boot/tegra2-public-firmware-fdts
	"

RDEPEND="${DEPEND}
	"

CROS_WORKON_LOCALNAME="u-boot"
CROS_WORKON_SUBDIR="files"

# This must be inherited *after* EGIT/CROS_WORKON variables defined
inherit cros-workon

UB_BUILD_DIR="${WORKDIR}/${ROOT}"
UB_BUILD_DIR_NB="${UB_BUILD_DIR%/}_nb"

U_BOOT_CONFIG_USE_PREFIX="u_boot_config_use_"
ALL_CONFIGS=(
	coreboot
	daisy
	seaboard
	waluigi
)
IUSE_CONFIGS=${ALL_CONFIGS[@]/#/${U_BOOT_CONFIG_USE_PREFIX}}

IUSE="${IUSE} ${IUSE_CONFIGS}"

REQUIRED_USE="${REQUIRED_USE} ^^ ( ${IUSE_CONFIGS} )"

get_current_u_boot_config() {
	local use_config
	for use_config in ${IUSE_CONFIGS}; do
		if use ${use_config}; then
			echo "chromeos_${use_config#${U_BOOT_CONFIG_USE_PREFIX}}_config"
			return
		fi
	done
	die "Unable to determine current U-Boot config."
}

netboot_required() {
	# Build netbootable image for Link unconditionally for now.
	# TODO (vbendeb): come up with a better scheme of determining what
	#                 platforms should always generate the netboot capable
	#                 legacy image.
	local board=$(get_current_board_no_variant)

	use factory-mode || [[ "${board}" == "link" ]]
}

# This function can only be called after make config
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
	grep "^${config}" "${boards_cfg}" | tr -s '[:space:]' ' ' | \
		cut -d' ' -f${i}
}

umake() {
	# Add `ARCH=` to reset ARCH env and let U-Boot choose it.
	ARCH= emake ${COMMON_MAKE_FLAGS} $@
}

src_configure() {
	export LDFLAGS=$(raw-ldflags)

	CROS_U_BOOT_CONFIG="$(get_current_u_boot_config)"
	elog "Using U-Boot config: ${CROS_U_BOOT_CONFIG}"

	# Firmware related binaries are compiled with 32-bit toolchain
	# on 64-bit platforms
	if use amd64 ; then
		CROSS_PREFIX="i686-pc-linux-gnu-"
	else
		CROSS_PREFIX="${CHOST}-"
	fi

	COMMON_MAKE_FLAGS="CROSS_COMPILE=${CROSS_PREFIX}"
	COMMON_MAKE_FLAGS+=" VBOOT=${ROOT%/}/usr"
	COMMON_MAKE_FLAGS+=" DEV_TREE_SEPARATE=1"
	if use dev; then
		# Avoid hiding the errors and warnings
		COMMON_MAKE_FLAGS+=" -s"
	else
		COMMON_MAKE_FLAGS+=" -k"
		COMMON_MAKE_FLAGS+=" WERROR=y"
	fi
	if use x86 || use amd64 || use cros-debug; then
		COMMON_MAKE_FLAGS+=" VBOOT_DEBUG=1"
	fi
	if use profiling; then
		COMMON_MAKE_FLAGS+=" VBOOT_PERFORMANCE=1"
	fi

	local BUILD_FLAGS="O=${UB_BUILD_DIR}"

	umake ${BUILD_FLAGS} distclean
	umake ${BUILD_FLAGS} ${CROS_U_BOOT_CONFIG}

	if netboot_required; then
		BUILD_FLAGS=" O=${UB_BUILD_DIR_NB}"
		BUILD_FLAGS+=" BUILD_FACTORY_IMAGE=1"
		umake ${BUILD_FLAGS} distclean
		umake ${BUILD_FLAGS} ${CROS_U_BOOT_CONFIG}
	fi
}

src_compile() {
	tc-export BUILD_CC
	local BUILD_FLAGS="O=${UB_BUILD_DIR}"

	umake ${BUILD_FLAGS} HOSTCC=${BUILD_CC} HOSTSTRIP=true all

	if netboot_required; then
		BUILD_FLAGS="O=${UB_BUILD_DIR_NB}"
		BUILD_FLAGS+=" BUILD_FACTORY_IMAGE=1"
		umake ${BUILD_FLAGS} HOSTCC=${BUILD_CC} HOSTSTRIP=true all
	fi
}

src_install() {
	local inst_dir="/firmware"
	local files_to_copy="System.map u-boot.bin"
	local ub_vendor="$(get_config_var ${CROS_U_BOOT_CONFIG} VENDOR)"
	local ub_board="$(get_config_var ${CROS_U_BOOT_CONFIG} BOARD)"
	local ub_arch="$(get_config_var ${CROS_U_BOOT_CONFIG} ARCH)"
	local file
	local dts_dir

	# Daisy and its variants need an SPL binary.
	if use u_boot_config_use_daisy; then
		files_to_copy+=" spl/${ub_board}-spl.bin"
	fi

	insinto "${inst_dir}"
	for file in ${files_to_copy}; do
		doins "${UB_BUILD_DIR}/${file}"
	done
	newins "${UB_BUILD_DIR}/u-boot" u-boot.elf

	if netboot_required; then
		newins "${UB_BUILD_DIR_NB}/u-boot.bin" u-boot_netboot.bin
		newins "${UB_BUILD_DIR_NB}/u-boot" u-boot_netboot.elf
	fi

	insinto "${inst_dir}/dts"
	for dts_dir in "board/${ub_vendor}/dts" \
			"board/${ub_vendor}/${ub_board}" \
			"arch/${ub_arch}/dts" \
			cros/dts; do
		files_to_copy="$(find ${dts_dir} -regex '.*\.dtsi?')"
		elog "Installing device tree files in ${dts_dir}"
		if [ -n "${files_to_copy}" ]; then
			doins ${files_to_copy}
		fi
	done
}

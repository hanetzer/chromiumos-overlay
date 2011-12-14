# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="ce8a72f786d03c14dfeea1c930e84b207320c452"
CROS_WORKON_PROJECT="chromiumos/third_party/u-boot"

inherit cros-debug toolchain-funcs cros-board flag-o-matic

DESCRIPTION="Das U-Boot boot loader"
HOMEPAGE="http://www.denx.de/wiki/U-Boot"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="arm x86"
IUSE="profiling"

DEPEND=">=chromeos-base/vboot_reference-firmware-0.0.1-r175
	!sys-boot/x86-firmware-fdts
	!sys-boot/tegra2-public-firmware-fdts
	"

RDEPEND="${DEPEND}
	"

CROS_WORKON_LOCALNAME="u-boot"
CROS_WORKON_SUBDIR="files"

# This must be inherited *after* EGIT/CROS_WORKON variables defined
inherit cros-workon

UB_BUILD_DIR="${WORKDIR}/${ROOT}"

U_BOOT_CONFIG_USE_PREFIX="u_boot_config_use_"
ALL_CONFIGS=(
	coreboot
	seaboard
	waluigi
)
IUSE_CONFIGS=${ALL_CONFIGS[@]/#/${U_BOOT_CONFIG_USE_PREFIX}}

U_BOOT_FDT_USE_PREFIX="u_boot_fdt_use_"
ALL_FDTS=(
	alex
	lumpy
	mario
	stumpy
	tegra2-aebl
	tegra2-arthur
	tegra2-asymptote
	tegra2-dev-board
	tegra2-kaen
	tegra2-seaboard
	tegra3-waluigi
)
IUSE_FDTS=${ALL_FDTS[@]/#/${U_BOOT_FDT_USE_PREFIX}}

# TODO(vbendeb): this will have to be populated when it becomes necessary to
# build different config flavors.
ALL_UBOOT_FLAVORS=''
IUSE="${IUSE} ${IUSE_CONFIGS} ${IUSE_FDTS} ${ALL_UBOOT_FLAVORS}"

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

get_current_u_boot_fdt() {
	local use_fdt
	for use_fdt in ${IUSE_FDTS}; do
		if use ${use_fdt}; then
			echo ${use_fdt#${U_BOOT_FDT_USE_PREFIX}}
			return
		fi
	done
	local ub_soc="$(get_config_var ${CROS_U_BOOT_CONFIG} SOC)"
	local ub_board="$(get_config_var ${CROS_U_BOOT_CONFIG} BOARD)"
	echo "${ub_soc}-${ub_board}"
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

	CROS_FDT_FILE="$(get_current_u_boot_fdt)"
	elog "Using device tree:   ${CROS_FDT_FILE}"

	COMMON_MAKE_FLAGS="CROSS_COMPILE=${CHOST}-"
	COMMON_MAKE_FLAGS+=" O=${UB_BUILD_DIR}"
	COMMON_MAKE_FLAGS+=" -k"
	COMMON_MAKE_FLAGS+=" VBOOT=${ROOT%/}/usr"
	COMMON_MAKE_FLAGS+=" DEV_TREE_SEPARATE=1"
	if [ "arm" = "${ARCH}" ]; then
		COMMON_MAKE_FLAGS+=" USE_PRIVATE_LIBGCC=yes"
	fi
	if use cros-debug; then
		COMMON_MAKE_FLAGS+=" VBOOT_DEBUG=1"
	fi
	if use profiling; then
		COMMON_MAKE_FLAGS+=" VBOOT_PERFORMANCE=1"
	fi
	COMMON_MAKE_FLAGS+=" DEV_TREE_SRC=${CROS_FDT_FILE}"

	umake distclean
	umake ${CROS_U_BOOT_CONFIG}
}

src_compile() {
	tc-getCC
	umake HOSTCC=${CC} HOSTSTRIP=true all
}

src_install() {
	local inst_dir="/firmware"
	local files_to_copy="System.map u-boot.bin"
	local ub_boarddir="$(grep CONFIG_BOARDDIR
			${UB_BUILD_DIR}/include/autoconf.mk |
			sed 's/.*="\(.*\)"/\1/')"
	local file

	insinto "${inst_dir}"
	for file in ${files_to_copy}; do
		doins "${UB_BUILD_DIR}/${file}"
	done
	newins "${UB_BUILD_DIR}/u-boot" u-boot.elf

	insinto "${inst_dir}/dtb"
	elog "Using fdt: ${CROS_FDT_FILE}.dtb"
	newins "${UB_BUILD_DIR}/u-boot.dtb" "${CROS_FDT_FILE}.dtb"

	insinto "${inst_dir}/dts"
	doins ${ub_boarddir}/*.dts
}

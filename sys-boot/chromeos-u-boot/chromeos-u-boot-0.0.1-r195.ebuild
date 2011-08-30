# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="569408cfc87ca2cc9a45e1ebbb934624788610bf"
CROS_WORKON_PROJECT="chromiumos/third_party/u-boot"

inherit cros-debug toolchain-funcs

DESCRIPTION="Das U-Boot boot loader"
HOMEPAGE="http://www.denx.de/wiki/U-Boot"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="arm x86"
UB_BOARDS="alex mario stumpy lumpy"
IUSE="profiling ${UB_BOARDS}"

REQUIRED_USE="^^ ( ${UB_BOARDS} arm )"

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

# TODO(vbendeb): this will have to be populated when it becomes necessary to
# build different config flavors.
ALL_UBOOT_FLAVORS=''
IUSE="${IUSE} ${ALL_UBOOT_FLAVORS}"

src_configure() {
	local ub_arch="$(tc-arch-kernel)"

	local ub_board="$(echo "${PKG_CONFIG#pkg-config-}" | tr _ '-')"

	COMMON_MAKE_FLAGS="ARCH=${ub_arch}"
	COMMON_MAKE_FLAGS+=" CROSS_COMPILE=${CHOST}-"
	COMMON_MAKE_FLAGS+=" O=${UB_BUILD_DIR}"
	COMMON_MAKE_FLAGS+=" -k"

	CROS_FDT_FILE="${ub_board#x86-}";

	case "${ub_arch}" in
		(arm)	CROS_U_BOOT_CONFIG='chromeos_tegra2_twostop_config' ;
			CROS_FDT_DIR="board/nvidia/seaboard"
			COMMON_MAKE_FLAGS+=" USE_PRIVATE_LIBGCC=yes" ;;
		(i386)	CROS_U_BOOT_CONFIG='coreboot-x86_config'
			CROS_FDT_DIR="board/chromebook-x86/coreboot" ;;
		(*) die "can not build for unknown architecture ${ub_arch}";;
	esac

	elog "Using U-Boot config: ${CROS_U_BOOT_CONFIG}"

	COMMON_MAKE_FLAGS+=" VBOOT=${ROOT%/}/usr"
	COMMON_MAKE_FLAGS+=" DEV_TREE_SEPARATE=1"

	if use cros-debug; then
		COMMON_MAKE_FLAGS+=" VBOOT_DEBUG=1"
	fi
	if use profiling; then
		COMMON_MAKE_FLAGS+=" VBOOT_PERFORMANCE=1"
	fi
	if [ -n "${CROS_FDT_FILE}" ]; then
		COMMON_MAKE_FLAGS+=" DEV_TREE_SRC=${CROS_FDT_FILE}"
	fi

	emake \
		${COMMON_MAKE_FLAGS} \
		distclean
	emake \
		${COMMON_MAKE_FLAGS} \
		${CROS_U_BOOT_CONFIG}
}

src_compile() {
	tc-getCC

	emake \
		${COMMON_MAKE_FLAGS} \
		HOSTCC=${CC} \
		HOSTSTRIP=true \
		all
}

src_install() {
	local config
	local inst_dir

	if use x86; then
		inst_dir='/coreboot'
	else
		inst_dir='/u-boot'
	fi

	dodir "${inst_dir}"
	insinto "${inst_dir}"

	local files_to_copy='System.map u-boot.bin'

	for file in ${files_to_copy}; do
		doins "${UB_BUILD_DIR}/${file}"
	done

	newins "${UB_BUILD_DIR}/u-boot" u-boot.elf

	dodir "${inst_dir}/dtb"
	insinto "${inst_dir}/dtb"

	elog "Using fdt: ${CROS_FDT_FILE}.dtb"
	newins "${UB_BUILD_DIR}/u-boot.dtb" "${CROS_FDT_FILE}.dtb"

	dodir "${inst_dir}/dts"
	insinto "${inst_dir}/dts"

	doins ${CROS_FDT_DIR}/*.dts
}

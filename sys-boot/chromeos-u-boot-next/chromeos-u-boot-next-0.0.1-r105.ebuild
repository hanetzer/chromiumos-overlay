# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="b32cc0f53663dd3a3f71daaceaeb12db7a3b5725"

inherit toolchain-funcs

DESCRIPTION="Das U-Boot boot loader"
HOMEPAGE="http://www.denx.de/wiki/U-Boot"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="arm"
IUSE=""
PROVIDE="virtual/u-boot"

RDEPEND=""
DEPEND="arm? ( >=chromeos-base/vboot_reference-firmware-0.0.1-r72 )
	!sys-boot/u-boot"

CROS_WORKON_PROJECT="u-boot-next"
CROS_WORKON_LOCALNAME="u-boot-next"
CROS_WORKON_SUBDIR="files"

# This must be inherited *after* EGIT/CROS_WORKON variables defined
inherit cros-workon

BUILD_ROOT="${WORKDIR}/${P}/builds"


# The following will take the three first words, each with trailing underscore
# out of CHROMEOS_U_BOOT_CONFIG and use it as the u-boot configuration prefix.
# TODO(vbendeb): clean up overlay make.conf files to straighten use of
# CHROMEOS_U_BOOT_CONFIG, then CONFIG_PREFIX could be set equal
# CHROMEOS_U_BOOT_CONFIG
CONFIG_PREFIX="$(expr \
    "${CHROMEOS_U_BOOT_CONFIG}" : '\(\([a-z0-9]\+_\)\{3\}\)')"

ALL_UBOOT_FLAVORS='developer flasher normal recovery stub'
IUSE="${ALL_UBOOT_FLAVORS}"

get_required_configs() {
	local flavor
	local all_configs=''
	local required_configs=''

	for flavor in ${ALL_UBOOT_FLAVORS}; do
		local config
		config=" ${CONFIG_PREFIX}${flavor}_config"
		if use "${flavor}"; then
			required_configs+="${config}"
		fi
		all_configs+="${config}"
	done

	# If no particular config(s) is(are) requested through USE flags,
	# build all of them.
	if [ -z "${required_configs}" ]; then
		echo -n "${all_configs}"
	else
		echo -n "${required_configs}"
	fi
}

REQUIRED_UBOOT_CONFIGS="$(get_required_configs)"

src_configure() {
	local config

	for config in ${REQUIRED_UBOOT_CONFIGS}; do
		local build_root="${BUILD_ROOT}/${config}"
		elog "Using U-Boot config: ${config}"

		emake \
		  O="${build_root}" \
		  ARCH=$(tc-arch-kernel) \
		  CROSS_COMPILE="${CHOST}-" \
		  distclean
		emake \
		  O="${build_root}" \
		  ARCH=$(tc-arch-kernel) \
		  CROSS_COMPILE="${CHOST}-" \
		  USE_PRIVATE_LIBGCC=yes \
		  ${config} || die "U-Boot configuration ${config} failed"
	done
}

src_compile() {
	local config
	tc-getCC

	for config in ${REQUIRED_UBOOT_CONFIGS}; do
	  emake \
	    O="${BUILD_ROOT}/${config}" \
	    ARCH=$(tc-arch-kernel) \
	    CROSS_COMPILE="${CHOST}-" \
	    USE_PRIVATE_LIBGCC=yes \
	    HOSTCC=${CC} \
	    HOSTSTRIP=true \
	    VBOOT="${ROOT}/usr" \
	    all || die "U-Boot compile ${config} failed"
	done
}

src_install() {
	local config
	local build_root
	local common_files_installed='n'

	dodir /u-boot
	insinto /u-boot

	for config in ${REQUIRED_UBOOT_CONFIGS}; do
		local build_root="${BUILD_ROOT}/${config}"
		local dest_file_name="u-boot-${config#${CONFIG_PREFIX}}"

		dest_file_name="${dest_file_name%_config}.bin"
		newins "${build_root}/u-boot.bin" ${dest_file_name} || die

		if [ "${common_files_installed}" == 'n' ]; then
			doins "${build_root}/System.map" || die
			doins "${build_root}/include/autoconf.mk" || die
			dobin "${build_root}/tools/mkimage" || die
			common_files_installed='y'
		fi

		# TODO(vbendeb): remove this after transition to generation of
		# aggregate u-boot.bin is finished.
		if [ "${dest_file_name}" == "u-boot-recovery.bin" ]; then
			doins "${build_root}/u-boot.bin" || die
		fi
	done
}

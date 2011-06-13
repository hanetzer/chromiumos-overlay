# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="2ea2caf0bfd635d9208f006409b9e4436c34078b"
CROS_WORKON_PROJECT="chromiumos/third_party/u-boot-next"

inherit toolchain-funcs

DESCRIPTION="Das U-Boot boot loader"
HOMEPAGE="http://www.denx.de/wiki/U-Boot"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="arm x86"
IUSE="no_vboot_debug"

DEPEND="!sys-boot/chromeos-u-boot"

RDEPEND="${DEPEND}
	"

CROS_WORKON_LOCALNAME="u-boot-next"
CROS_WORKON_SUBDIR="files"

# This must be inherited *after* EGIT/CROS_WORKON variables defined
inherit cros-workon

BUILD_ROOT="${WORKDIR}/${P}/builds"

# TODO(vbendeb): this will have to be populated when it becomes necessary to
# build different config flavors.
ALL_UBOOT_FLAVORS=''
IUSE="${IUSE} ${ALL_UBOOT_FLAVORS}"
UB_ARCH="$(tc-arch-kernel)"
COMMON_MAKE_FLAGS="ARCH=${UB_ARCH} CROSS_COMPILE=${CHOST}-"

if ! use no_vboot_debug; then
	COMMON_MAKE_FLAGS+=" VBOOT_DEBUG=1"
fi

if [ "${UB_ARCH}" != "i386" ]; then
	COMMON_MAKE_FLAGS+=" USE_PRIVATE_LIBGCC=yes"
fi

get_required_configs() {
	case "${UB_ARCH}" in
		(arm) echo 'seaboard_config';;
		(i386) echo 'coreboot-x86_config';;
		(*) die "can not build for unknown architecture ${UB_ARCH}";;
	esac
}

src_configure() {
	local config
	for config in $(get_required_configs); do
		local build_root="${BUILD_ROOT}/${config}"
		elog "Using U-Boot config: ${config}"

		emake \
		  ${COMMON_MAKE_FLAGS} \
		  O="${build_root}" \
		  distclean
		emake \
		  ${COMMON_MAKE_FLAGS} \
		  O="${build_root}" \
		  ${config} || die "U-Boot configuration ${config} failed"
	done
}

src_compile() {
	local config
	tc-getCC

	for config in $(get_required_configs); do
	  emake \
	    ${COMMON_MAKE_FLAGS} \
	    O="${BUILD_ROOT}/${config}" \
	    HOSTCC=${CC} \
	    HOSTSTRIP=true \
	    CROS_CONFIG_PATH="${ROOT%/}/u-boot" \
	    all || die "U-Boot compile ${config} failed"
	done
}

src_install() {
	local config
	local build_root
	local mkimage_installed='n'

	dodir /u-boot
	insinto /u-boot

	for config in $(get_required_configs); do
		local build_root="${BUILD_ROOT}/${config}"
		local files_to_copy='System.map include/autoconf.mk u-boot.bin'

		for file in ${files_to_copy}; do
			local dest_file="${config%_config}.$(basename $file)"
			newins "${build_root}/${file}" ${dest_file} || die
		done
		if [ "${mkimage_installed}" == 'n' ]; then
			dobin "${build_root}/tools/mkimage" || die
			mkimage_installed='y'
		fi
	done
}

# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="b3a2ce1de5bd4e253735d860522370c7c723945e"
CROS_WORKON_PROJECT="chromiumos/third_party/u-boot-next"

inherit toolchain-funcs

DESCRIPTION="Das U-Boot boot loader"
HOMEPAGE="http://www.denx.de/wiki/U-Boot"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="arm x86"
IUSE="+vboot_debug"

# TODO(clchiou): coreboot couldn't care less about vboot for now
DEPEND="arm? ( chromeos-base/vboot_reference-firmware )
	!sys-boot/chromeos-u-boot"

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

# TODO(clchiou): coreboot couldn't care less about vboot for now
use arm && COMMON_MAKE_FLAGS+=" VBOOT=${ROOT%/}/usr"
if use vboot_debug; then
	use arm && COMMON_MAKE_FLAGS+=" VBOOT_DEBUG=1"
fi

if [ "${UB_ARCH}" != "i386" ]; then
	COMMON_MAKE_FLAGS+=" USE_PRIVATE_LIBGCC=yes"
fi

get_required_config() {
	case "${UB_ARCH}" in
		(arm) echo 'chromeos_seaboard_onestop_config';;
		(i386) echo 'coreboot-x86_config';;
		(*) die "can not build for unknown architecture ${UB_ARCH}";;
	esac
}

get_fdt_name() {
	local name=${PKG_CONFIG#pkg-config-}

	if use arm; then
		echo "${name}" | tr _ '-'
	fi
}

# We will supply an fdt at run time
COMMON_MAKE_FLAGS+=" DEV_TREE_SEPARATE=1 DEV_TREE_SRC=$(get_fdt_name)"

src_configure() {
	local config
	config=$(get_required_config)
	elog "Using U-Boot config: ${config}"
	dtb=$(get_fdt_name)
	if [ -n "${dtb}" ]; then
		elog "Using fdt: ${dtb}"
	else
		elog "Not building fdt"
	fi

	emake \
		${COMMON_MAKE_FLAGS} \
		distclean
	emake \
		${COMMON_MAKE_FLAGS} \
		${config} || die "U-Boot configuration ${config} failed"
}

src_compile() {
	local config
	tc-getCC

	config=$(get_required_config)
	emake \
		${COMMON_MAKE_FLAGS} \
		HOSTCC=${CC} \
		HOSTSTRIP=true \
		all || die "U-Boot compile ${config} failed"
}

src_install() {
	local config

	dodir /u-boot
	insinto /u-boot

	config=$(get_required_config)
	local files_to_copy='System.map include/autoconf.mk u-boot.bin'

	if [ -n "$(get_fdt_name)" ]; then
		files_to_copy+=" u-boot.dtb"
	fi

	for file in ${files_to_copy}; do
		doins "${file}" || die
	done

	if use x86; then
		elog "Building on x86, installing coreboot payload."
		dodir /coreboot
		insinto /coreboot
		newins "u-boot" u-boot.elf || die
	fi
}

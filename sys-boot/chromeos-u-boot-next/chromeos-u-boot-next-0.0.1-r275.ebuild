# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="0758bf079fade268722196d2412eeddc3c20ccc2"
CROS_WORKON_PROJECT="chromiumos/third_party/u-boot-next"

inherit cros-debug toolchain-funcs

DESCRIPTION="Das U-Boot boot loader"
HOMEPAGE="http://www.denx.de/wiki/U-Boot"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="arm x86"
IUSE=""

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
if use cros-debug; then
	use arm && COMMON_MAKE_FLAGS+=" VBOOT_DEBUG=1"
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

if use arm; then
	COMMON_MAKE_FLAGS+=" USE_PRIVATE_LIBGCC=yes"
	# We will supply an fdt at run time
	COMMON_MAKE_FLAGS+=" DEV_TREE_SEPARATE=1 DEV_TREE_SRC=$(get_fdt_name)"
fi


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
	local inst_dir

	if use x86; then
		inst_dir='/coreboot'
	else
		inst_dir='/u-boot'
	fi

	dodir "${inst_dir}"
	insinto "${inst_dir}"

	config=$(get_required_config)
	local files_to_copy='System.map include/autoconf.mk u-boot.bin'

	if [ -n "$(get_fdt_name)" ]; then
		files_to_copy+=" u-boot.dtb"
	fi

	for file in ${files_to_copy}; do
		doins "${file}" || die
	done

	if use x86; then
		newins "u-boot" u-boot.elf || die
	fi
}

# Copyright 2012 The Chromium OS Authors.
# Distributed under the terms of the GNU General Public License v2

# Change this version number when any change is made to configs/files under
# libpayload and an auto-revbump is required.
# VERSION=REVBUMP-0.0.12

EAPI=4
CROS_WORKON_COMMIT="d8909e242c17ebae8b3efbb3463c8d47b9fcb3f3"
CROS_WORKON_TREE="6637ba323ba75ad71b516c82681dab30affe330d"
CROS_WORKON_PROJECT="chromiumos/third_party/coreboot"

DESCRIPTION="coreboot's libpayload library"
HOMEPAGE="http://www.coreboot.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="coreboot-sdk"

CROS_WORKON_LOCALNAME="coreboot"

# Don't strip to ease remote GDB use (cbfstool strips final binaries anyway)
STRIP_MASK="*"

inherit cros-workon cros-board toolchain-funcs coreboot-sdk

src_compile() {
	local src_root="payloads/libpayload"
	local board=$(get_current_board_with_variant)

	if ! use coreboot-sdk; then
		tc-getCC
		# Export the known cross compilers so there isn't a reliance
		# on what the default profile is for exporting a compiler. The
		# reasoning is that the firmware may need more than one to build
		# and boot.
		export CROSS_COMPILE_i386="i686-pc-linux-gnu-"
		# For coreboot.org upstream architecture naming.
		export CROSS_COMPILE_x86="i686-pc-linux-gnu-"
		export CROSS_COMPILE_mipsel="mipsel-cros-linux-gnu-"
		export CROSS_COMPILE_arm64="aarch64-cros-linux-gnu-"
		export CROSS_COMPILE_arm="armv7a-cros-linux-gnu- armv7a-cros-linux-gnueabi-"
	else
		export CROSS_COMPILE_x86=${COREBOOT_SDK_PREFIX_x86_32}
		export CROSS_COMPILE_mipsel=${COREBOOT_SDK_PREFIX_mips}
		export CROSS_COMPILE_arm64=${COREBOOT_SDK_PREFIX_arm64}
		export CROSS_COMPILE_arm=${COREBOOT_SDK_PREFIX_arm}
	fi

	# we have all kinds of userland-cruft in CFLAGS that has no place in firmware.
	# coreboot ignores CFLAGS, libpayload doesn't, so prune it.
	unset CFLAGS

	if [[ ! -s "${FILESDIR}/configs/config.${board}" ]]; then
		board=$(get_current_board_no_variant)
	fi

	local board_config="$(realpath "${FILESDIR}/configs/config.${board}")"

	[ -f "${board_config}" ] || die "${board_config} does not exist"

	# get into the source directory
	pushd "${src_root}"

	# nuke build artifacts potentially present in the source directory
	rm -rf build build_gdb .xcompile

	# Configure and build
	cp "${board_config}" .config
	yes "" | \
	emake obj="build" objutil="objutil" oldconfig
	emake obj="build" objutil="objutil"

	# Build a second set of libraries with GDB support for developers
	( cat .config; echo "CONFIG_LP_REMOTEGDB=y" ) > .config.gdb
	yes "" | \
	emake obj="build_gdb" objutil="objutil" DOTCONFIG=.config.gdb oldconfig
	emake obj="build_gdb" objutil="objutil" DOTCONFIG=.config.gdb

	popd
}

src_install() {
	local src_root="payloads/libpayload"

	pushd "${src_root}"

	emake obj="build_gdb" DESTDIR="${D}/firmware" DOTCONFIG=.config.gdb install
	mv "${D}/firmware/libpayload" "${D}/firmware/libpayload_gdb"
	emake obj="build" DESTDIR="${D}/firmware" install
}

# Copyright 2012 The Chromium OS Authors.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="1a5b4d70dd0a88fa7399f05816ef5a24ea56b61d"
CROS_WORKON_TREE="30525c2699e994b3e16d5d8480411350ec38bcde"
CROS_WORKON_PROJECT="chromiumos/third_party/coreboot"

DESCRIPTION="coreboot's libpayload library"
HOMEPAGE="http://www.coreboot.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND=""
DEPEND=""

CROS_WORKON_LOCALNAME="coreboot"

# Don't strip to ease remote GDB use (cbfstool strips final binaries anyway)
STRIP_MASK="*"

inherit cros-workon cros-board toolchain-funcs

src_compile() {
	tc-getCC
	local src_root="payloads/libpayload"
	local board=$(get_current_board_with_variant)

	# Export the known cross compilers so there isn't a reliance
	# on what the default profile is for exporting a compiler. The
	# reasoning is that the firmware may need more than one to build
	# and boot.
	export CROSS_COMPILE_i386="i686-pc-linux-gnu-"
	# For coreboot.org upstream architecture naming.
	export CROSS_COMPILE_x86="i686-pc-linux-gnu-"
	export CROSS_COMPILE_mipsel="mipsel-cros-linux-gnu-"
	# aarch64: used on chromeos-2013.04
	export CROSS_COMPILE_aarch64="aarch64-cros-linux-gnu-"
	# arm64: used on coreboot upstream
	export CROSS_COMPILE_arm64="aarch64-cros-linux-gnu-"
	export CROSS_COMPILE_arm="armv7a-cros-linux-gnu- armv7a-cros-linux-gnueabi-"

	elog "Toolchain:\n$(sh util/xcompile/xcompile)\n"

	if [[ ! -s "${FILESDIR}/configs/config.${board}" ]]; then
		board=$(get_current_board_no_variant)
	fi

	local board_config="$(realpath "${FILESDIR}/configs/config.${board}")"

	[ -f "${board_config}" ] || die "${board_config} does not exist"

	# get into the source directory
	pushd "${src_root}"

	# nuke build artifacts potentially present in the source directory
	emake distclean

	# Configure and build
	cp "${board_config}" .config
	yes "" | emake oldconfig
	emake obj="build"
	cp .config build

	# Build a second set of libraries with GDB support for developers
	cp "${board_config}" .config
	sed -i "s/# CONFIG_LP_REMOTEGDB is not set/CONFIG_LP_REMOTEGDB=y/" .config
	yes "" | emake oldconfig
	emake obj="build_gdb"
	cp .config build_gdb

	popd
}

install_libpayload() {
	local suffix="$1"
	local src_root="payloads/libpayload"
	local build_root="${src_root}/build${suffix}"
	local destdir="/firmware/libpayload${suffix}"
	local archdir=""

	if [[ -n "${CHROMEOS_LIBPAYLOAD_ARCH_DIR}" ]] ; then
	      	archdir="${CHROMEOS_LIBPAYLOAD_ARCH_DIR}"
	else
		case "${ARCH}" in
		amd64) archdir="x86";;
		*) archdir=${ARCH};;
		esac
	fi

	insinto ${destdir}/lib
	doins ${build_root}/libpayload.a
	if [ -f ${src_root}/lib/libpayload.ldscript ]; then
		doins ${src_root}/lib/libpayload.ldscript
	fi
	if [ -f ${src_root}/arch/${archdir}/libpayload.ldscript ]; then
		doins ${src_root}/arch/${archdir}/libpayload.ldscript
	fi

	insinto ${destdir}/lib/${archdir}
	doins ${build_root}/head.o

	insinto ${destdir}/include
	doins ${build_root}/libpayload-config.h
	for file in `cd ${src_root} && find include -name *.h -type f`; do \
		insinto ${destdir}/`dirname ${file}`; \
		doins ${src_root}/${file}; \
	done

	exeinto ${destdir}/bin
	insinto ${destdir}/bin
	doexe ${src_root}/bin/lpgcc
	doexe ${src_root}/bin/lpas
	doins ${src_root}/bin/lp.functions

	insinto ${destdir}
	newins ${src_root}/.xcompile libpayload.xcompile
	newins ${build_root}/.config libpayload.config
}

src_install() {
	install_libpayload ""
	install_libpayload "_gdb"
}

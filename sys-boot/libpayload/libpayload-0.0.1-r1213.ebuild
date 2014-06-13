# Copyright 2012 The Chromium OS Authors.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="5da840c5d1f3d8fdf8cc0d7c44772bf0cef03fbb"
CROS_WORKON_TREE="ac8a5be7a5d8ad5ace034785a6ce175157c65a55"
CROS_WORKON_PROJECT="chromiumos/third_party/coreboot"

DESCRIPTION="coreboot's libpayload library"
HOMEPAGE="http://www.coreboot.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="-* amd64 arm arm64 x86"
IUSE=""

RDEPEND=""
DEPEND=""

CROS_WORKON_LOCALNAME="coreboot"

# Don't strip to ease remote GDB use (cbfstool strips final binaries anyway)
STRIP_MASK="*"

inherit cros-workon cros-board toolchain-funcs

src_compile() {
	tc-getCC
	local board=$(get_current_board_with_variant)

	# Firmware related binaries are compiled with a 32-bit toolchain
	# on 64-bit platforms
	if use amd64 ; then
		export CROSS_COMPILE="i686-pc-linux-gnu-"
		export CC="${CROSS_COMPILE}gcc"
	else
		export CROSS_COMPILE=${CHOST}-
	fi

	local extra_flags=""
	if use x86 || use amd64 ; then
		extra_flags="-mpreferred-stack-boundary=2 -ffunction-sections"
	elif use arm || use arm64 ; then
		extra_flags="-ffunction-sections"
	fi

	local libpayloaddir="payloads/libpayload"
	if [[ ! -s "${libpayloaddir}/configs/config.${board}" ]]; then
		board=$(get_current_board_no_variant)
	fi

	local board_config="${libpayloaddir}/configs/config.${board}"

	[ -f "${board_config}" ] || die "${board_config} does not exist"

	cp "${board_config}" "${libpayloaddir}"/.config
	echo "# CONFIG_LP_REMOTEGDB is not set" >> "${libpayloaddir}"/.config
	emake -C "${libpayloaddir}" oldconfig
	emake -C "${libpayloaddir}" obj="build" EXTRA_CFLAGS="${extra_flags}"

	# Build a second set of libraries with GDB support for developers
	cp "${board_config}" "${libpayloaddir}"/.config
	echo "CONFIG_LP_REMOTEGDB=y" >> "${libpayloaddir}"/.config
	emake -C "${libpayloaddir}" oldconfig
	emake -C "${libpayloaddir}" obj="build_gdb" EXTRA_CFLAGS="${extra_flags}"
}

install_libpayload() {
	local suffix="$1"
	local src_root="payloads/libpayload/"
	local build_root="${src_root}/build${suffix}"
	local destdir="/firmware/libpayload${suffix}"

	local archdir=""
	if use x86 || use amd64 ; then
		archdir="x86"
	elif use arm ; then
		archdir="arm"
	elif use arm64 ; then
		archdir="arm64"
	fi

	insinto "${destdir}"/lib
	doins "${build_root}"/libpayload.a
	if [ -f "${src_root}"/lib/libpayload.ldscript ]; then
		doins "${src_root}"/lib/libpayload.ldscript
	fi
	if [ -f "${src_root}"/arch/${archdir}/libpayload.ldscript ]; then
		doins "${src_root}"/arch/${archdir}/libpayload.ldscript
	fi

	insinto "${destdir}"/lib/"${archdir}"
	doins "${build_root}"/head.o

	insinto "${destdir}"/include
	doins "${build_root}"/libpayload-config.h
	for file in `cd ${src_root} && find include -name *.h -type f`; do \
		insinto "${destdir}"/`dirname ${file}`; \
		doins "${src_root}"/"${file}"; \
	done

	exeinto "${destdir}"/bin
	insinto "${destdir}"/bin
	doexe "${src_root}"/bin/lpgcc
	doexe "${src_root}"/bin/lpas
	doins "${src_root}"/bin/lp.functions

	insinto "${destdir}"
	newins "${src_root}"/.config libpayload.config
}

src_install() {
	install_libpayload ""
	install_libpayload "_gdb"
}

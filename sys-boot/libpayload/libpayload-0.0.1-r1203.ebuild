# Copyright 2012 The Chromium OS Authors.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="c8127e4ac9811517f6147cf019ba6a948cdaa4a5"
CROS_WORKON_TREE="33a2807e900434c2d8378133eceb26b5089f4632"
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
	emake -C "${libpayloaddir}" oldconfig || \
		die "libpayload make oldconfig failed"
	emake -C "${libpayloaddir}" \
		EXTRA_CFLAGS="${extra_flags}" || \
		die "libpayload build failed"
}

src_install() {
	local src_root="payloads/libpayload/"
	local build_root="${src_root}/build"
	local destdir="/firmware/libpayload"

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

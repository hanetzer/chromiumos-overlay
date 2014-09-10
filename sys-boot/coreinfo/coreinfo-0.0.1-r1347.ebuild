# Copyright 2012 The Chromium OS Authors.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="13c30c50a9e8a7f3c48673a2f6c144ba546129b6"
CROS_WORKON_TREE="ee13e01ba36879903a0ca4b56ae83b75ed471b5f"
CROS_WORKON_PROJECT="chromiumos/third_party/coreboot"

DESCRIPTION="coreboot's coreinfo payload"
HOMEPAGE="http://www.coreboot.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"

RDEPEND="sys-boot/libpayload"
DEPEND="sys-boot/libpayload"

CROS_WORKON_LOCALNAME="coreboot"

inherit cros-workon toolchain-funcs

src_compile() {
	tc-getCC

	# Firmware related binaries are compiled with a 32-bit toolchain
	# on 64-bit platforms
	if use amd64 ; then
		export CROSS_COMPILE="i686-pc-linux-gnu-"
		export CC="${CROSS_COMPILE}gcc"
	else
		export CROSS_COMPILE=${CHOST}-
	fi

	local coreinfodir="payloads/coreinfo"
	cp "${coreinfodir}"/config.default "${coreinfodir}"/.config
	emake -C "${coreinfodir}" \
		LIBPAYLOAD_DIR="${ROOT}/firmware/libpayload/" \
		oldconfig \
		|| die "libpayload make oldconfig failed"
	emake -C "${coreinfodir}" \
		LIBPAYLOAD_DIR="${ROOT}/firmware/libpayload/" \
		|| die "libpayload build failed"
}

src_install() {
	local src_root="payloads/coreinfo/"
	local build_root="${src_root}/build"
	local destdir="/firmware/coreinfo"

	insinto "${destdir}"
	doins "${build_root}"/coreinfo.elf
}

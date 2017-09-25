# Copyright (c) 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit cmake-utils

DESCRIPTION="Intel(R) Dynamic Platform & Thermal Framework"
HOMEPAGE="https://01.org/dptf/"
SRC_URI="https://github.com/01org/dptf/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0 GPL-2 BSD"
SLOT="0"
KEYWORDS="-* amd64 x86"
IUSE="debug"

# Makefile for DPTF policies
CMAKE_USE_DIR="${S}/DPTF/Linux"
# Makefile for ESIF daemon
ESIF_BUILD_DIR="ESIF/Products/ESIF_UF/Linux"
# Makefile for ESIF compression library
ESIFCMP_BUILD_DIR="ESIF/Products/ESIF_CMP/Linux"
# Makefile for ESIF web server
ESIFWS_BUILD_DIR="ESIF/Products/ESIF_WS/Linux"

DEPEND="sys-apps/dbus
	sys-libs/ncurses sys-libs/readline"
RDEPEND="${DEPEND}"

src_prepare() {
	# This fixes a warning unterminated '#pragma.
	# See crbug.com/755573
	epatch "${FILESDIR}"/dptf-fix-unterminated-pragma.patch
	# This fixes a warning delete-non-virtual-dtor
	epatch "${FILESDIR}"/dptf-fix-delete-non-virtual-dtor.patch
}

src_configure() {
	# cmake configuration for DPTF policy shared libraries
	local mycmakeargs=( -DCHROMIUM_BUILD=YES )
	use x86 && mycmakeargs+=( -DBUILD_ARCH=32bit )
	use amd64 && mycmakeargs+=( -DBUILD_ARCH=64bit )
	cmake-utils_src_configure
}

src_compile() {
	# Build ESIF daemon
	local extra_cflags=""
	use debug && extra_cflags="Debug"

	for build_dir in "${ESIF_BUILD_DIR}" "${ESIFCMP_BUILD_DIR}" "${ESIFWS_BUILD_DIR}"; do
		emake \
			-C ${build_dir} \
			CC="$(tc-getCC)" \
			BUILD="${extra_cflags}" \
			OS=Chrome
	done

	# Build DPTF policy shared libraries
	cmake-utils_src_compile
}

src_install() {
	# Install ESIF daemon and configuration files
	local startcmd_src_dir="ESIF/Packages/Installers/chrome"
	dobin "${ESIF_BUILD_DIR}/esif_ufd"
	insinto "/etc/dptf"
	doins ESIF/Packages/DSP/dsp.dv
	doins "${FILESDIR}/get_dptf_for_board"
	insinto "/etc/init"
	doins "${FILESDIR}/dptf.conf"

	# Install ESIF loadable libraries
	dolib.so "${ESIFCMP_BUILD_DIR}/esif_cmp.so"
	dolib.so "${ESIFWS_BUILD_DIR}/esif_ws.so"

	# Install DPTF policy shared libraries
	local policy_build_dir="${BUILD_DIR}"/$(usex amd64 x64 x32)
	dolib.so "${policy_build_dir}/Dptf.so"
	dolib.so ${policy_build_dir}/DptfPolicyActive.so
	dolib.so ${policy_build_dir}/DptfPolicyCritical.so
	dolib.so ${policy_build_dir}/DptfPolicyPassive.so
}
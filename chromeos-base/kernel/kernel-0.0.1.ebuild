# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit toolchain-funcs

DESCRIPTION="Chrome OS Kernel"
HOMEPAGE="http://src.chromium.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 arm"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

src_unpack() {
	local files

	# Setup arch specific flags.
	#
	# For now, we require a clone of kernel-qualcomm next to
	# third_party/kernel if we want to do an ARM build.
	#
	if [ "${ARCH}" = "x86" ]; then
		files="${CHROMEOS_ROOT}/src/third_party/kernel/files"
		config_file="${files}"/chromeos/config/chromeos-intel-menlow
	elif [ "${ARCH}" = "arm" ]; then
		files="${CHROMEOS_ROOT}/src/third_party/kernel-qualcomm"
		config_file="${files}"/arch/arm/configs/qsd8650-st1_defconfig

		# kernel-qualcomm currently requires its own git clone
		[ -f "${config_file}" ] || \
			die "kernel-qualcomm requires its own git clone."
	else
		die no config file for arch: "${ARCH}"
	fi

	elog "Using kernel files: ${files}"
	mkdir -p "${S}"
	cp -ar "${files}"/* "${S}" || die

	# copy config
	elog "Using config file ${config_file}"
	cp "${config_file}" "${S}/.config"

	# make modules output directory
	mkdir "${S}"/mod_obj
}

src_compile() {
	emake ARCH=$(tc-arch-kernel) CROSS_COMPILE="${CHOST}-" || die
}

src_install() {
	dodir boot
	emake ARCH=$(tc-arch-kernel) INSTALL_PATH="${D}/boot" install || die
	emake ARCH=$(tc-arch-kernel) INSTALL_MOD_PATH="${D}" modules_install || die
	emake ARCH=$(tc-arch-kernel) INSTALL_MOD_PATH="${D}" firmware_install || die
}

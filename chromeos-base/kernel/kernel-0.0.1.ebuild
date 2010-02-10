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
	for i in bzImage modules firmware; do
		emake \
			ARCH=$(tc-arch-kernel) \
			CROSS_COMPILE="${CHOST}-" \
			$i || die Kernel compile failed on target $i
	done
}

src_install() {
	for i in modules_install firmware_install; do
		emake \
			ARCH=$(tc-arch-kernel) \
			CROSS_COMPILE="${CHOST}-" \
			INSTALL_MOD_PATH="${D}" \
			$i || die Kernel install failed on target $i
	done

	KCONFIG_NAME=$(ls "${D}"/lib/modules)

	# copy kernel, config, system.map
	dodir /boot
	cp -a "${S}"/arch/"${ARCH}"/boot/bzImage \
		"${D}/boot/vmlinuz-${KCONFIG_NAME}" || \
		cp -a "${S}"/arch/"${ARCH}"/boot/zImage \
		"${D}/boot/vmlinuz-${KCONFIG_NAME}" || die
	cp -a "${S}"/System.map "${D}/boot/System.map-${KCONFIG_NAME}" || die
	cp -a "${S}"/.config "${D}/boot/config-${KCONFIG_NAME}" || die

	ln -sf "vmlinuz-${KCONFIG_NAME}" "${D}"/boot/vmlinuz || die
	ln -sf "System.map-${KCONFIG_NAME}" "${D}"/boot/System.map || die
	ln -sf "config-${KCONFIG_NAME}" "${D}"/boot/config || die

	# copy modules and firmware
	mv "${D}"/lib/firmware "${D}"/lib/"${KCONFIG_NAME}" || die
	mkdir "${D}"/lib/firmware || die
	mv "${D}"/lib/"${KCONFIG_NAME}" "${D}"/lib/firmware/ || die
}


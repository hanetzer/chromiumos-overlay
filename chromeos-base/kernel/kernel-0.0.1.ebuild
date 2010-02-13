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

DEPEND="sys-apps/debianutils"
RDEPEND="${DEPEND}"

kernel=${CHROMEOS_KERNEL:-"kernel/files"}
files="${CHROMEOS_ROOT}/src/third_party/${kernel}"

if [ "${ARCH}" = "x86" ]; then
  config=${CHROMEOS_KERNEL_CONFIG:-"chromeos/config/chromeos-intel-menlow"}
elif [ "${ARCH}" = "arm" ]; then
  config=${CHROMEOS_KERNEL_CONFIG:-"versatile_defconfig"}
fi

src_unpack() {
	elog "Using kernel files: ${files}"

	mkdir -p "${S}"
	cp -ar "${files}"/* "${S}" || die
}

src_configure() {
	elog "Using kernel config file: ${config}"

	if [ "${ARCH}" = "x86" ]; then
		cp "${files}/${config}" "${S}/.config"
	elif [ "${ARCH}" = "arm" ]; then
		emake \
		  ARCH=$(tc-arch-kernel) \
		  CROSS_COMPILE="${CHOST}-" \
		  ${config} || die "Kernel config failed for ${config}"
        fi
}

src_compile() {
	emake \
          ARCH=$(tc-arch-kernel) \
          CROSS_COMPILE="${CHOST}-" || die
}

src_install() {
	dodir boot

	emake \
 	  ARCH=$(tc-arch-kernel) \
	  CROSS_COMPILE="${CHOST}-" \
          INSTALL_PATH="${D}/boot" \
          install || die

	emake \
          ARCH=$(tc-arch-kernel) \
          CROSS_COMPILE="${CHOST}-" \
          INSTALL_MOD_PATH="${D}" \
          modules_install || die

	emake \
          ARCH=$(tc-arch-kernel) \
          CROSS_COMPILE="${CHOST}-" \
          INSTALL_MOD_PATH="${D}" \
          firmware_install || die

	if [ "${ARCH}" = "arm" ]; then
		version=$(ls "${D}"/lib/modules)

		cp -a \
		   "${S}"/arch/"${ARCH}"/boot/zImage \
		   "${D}/boot/vmlinuz-${version}" || die

		cp -a \
		   "${S}"/System.map \
		   "${D}/boot/System.map-${version}" || die

		cp -a \
		   "${S}"/.config \
		   "${D}/boot/config-${version}" || die

		ln -sf "vmlinuz-${version}"    "${D}"/boot/vmlinuz    || die
		ln -sf "System.map-${version}" "${D}"/boot/System.map || die
		ln -sf "config-${version}"     "${D}"/boot/config     || die
	fi
}

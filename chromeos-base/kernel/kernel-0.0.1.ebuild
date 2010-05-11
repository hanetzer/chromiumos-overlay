# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit toolchain-funcs

DESCRIPTION="Chrome OS Kernel"
HOMEPAGE="http://src.chromium.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 arm"
IUSE="-compat_wireless -gobi"

DEPEND="sys-apps/debianutils"
RDEPEND=""

kernel=${CHROMEOS_KERNEL:-"kernel/files"}
files="${CHROMEOS_ROOT}/src/third_party/${kernel}"
vmlinux_text_base=${CHROMEOS_U_BOOT_VMLINUX_TEXT_BASE:-0x20008000}

# Use a single or split kernel config as specified in the board or variant
# make.conf overlay. Default to the arch specific split config if an
# overlay or variant does not set either CHROMEOS_KERNEL_CONFIG or
# CHROMEOS_KERNEL_SPLITCONFIG. CHROMEOS_KERNEL_CONFIG is set relative 
# to the root of the kernel source tree.

if [ -n "${CHROMEOS_KERNEL_CONFIG}" ]; then
	config="${files}/${CHROMEOS_KERNEL_CONFIG}"
else
	if [ "${ARCH}" = "x86" ]; then
		config=${CHROMEOS_KERNEL_SPLITCONFIG:-"chromeos-intel-menlow"}
	elif [ "${ARCH}" = "arm" ]; then
		config=${CHROMEOS_KERNEL_SPLITCONFIG:-"qsd8650-st1"}
	fi
fi

src_unpack() {
	elog "Using kernel files: ${files}"

	mkdir -p "${S}"
	cp -ar "${files}"/* "${S}" || die

	if use gobi; then
		# Until we can get these files upstreamed we will copy them
		# into the tree.  This is a temporary measure

		local partner="${CHROMEOS_ROOT}/src/partner_private"
		local gobi_files="${partner}/source-cromo_qualcomm-private/kernel/"
		local gobi_source="${S}/chromeos/drivers/gobi"

		elog "Using gobi files: ${gobi_files}"
		mkdir -p "${gobi_source}"
		cp -ar "${gobi_files}"/* "${gobi_source}"
	fi
 }

src_configure() {
	elog "Using kernel config: ${config}"

	if [ -n "${CHROMEOS_KERNEL_CONFIG}" ]; then
		cp -f "${config}" "${S}"/.config || die
	else
		chromeos/scripts/prepareconfig ${config} || die
	fi

	# Use default for any options not explitly set in splitconfig
	yes "" | emake ARCH=$(tc-arch-kernel) oldconfig || die

	if use compat_wireless; then
		"${S}"/chromeos/scripts/compat_wireless_config "${S}"
	fi
}

src_compile() {
	emake \
		ARCH=$(tc-arch-kernel) \
		CROSS_COMPILE="${CHOST}-" || die

	if use compat_wireless; then
		# compat-wireless support must be done after
		emake M=chromeos/compat-wireless \
			ARCH=$(tc-arch-kernel) \
			CROSS_COMPILE="${CHOST}-" || die
	fi
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

	if use compat_wireless; then
		# compat-wireless modules are built+installed separately
		# NB: the updates dir is handled specially by depmod
		emake M=chromeos/compat-wireless \
			ARCH=$(tc-arch-kernel) \
			CROSS_COMPILE="${CHOST}-" \
			INSTALL_MOD_DIR=updates \
			INSTALL_MOD_PATH="${D}" \
			modules_install || die
	fi

	if use gobi; then
		emake -C ${S}/chromeos/drivers/gobi \
 			DESTDIR="${D}" \
		  	HOST_MODULES_DIR=${S} \
			install || die "Cannot compile gobi modules"
	fi

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
		
		dodir /boot

		/usr/bin/mkimage -A "${ARCH}" \
							-O linux \
							-T kernel \
							-C none \
							-a ${vmlinux_text_base} \
							-e ${vmlinux_text_base} \
							-n kernel \
							-d "${D}"/boot/vmlinuz \
							"${D}"/boot/vmlinux.uimg || die
	fi
}

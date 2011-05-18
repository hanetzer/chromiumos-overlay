# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="2b13497bdb480572b9772493be1290318de46d41"
CROS_WORKON_PROJECT="chromiumos/third_party/kernel"

inherit toolchain-funcs
inherit binutils-funcs

DESCRIPTION="Chrome OS Kernel"
HOMEPAGE="http://www.chromium.org/"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 arm"
IUSE_KCONFIG="+kconfig_generic kconfig_atom kconfig_atom64 kconfig_tegra2"
IUSE="-fbconsole -initramfs -nfs ${IUSE_KCONFIG}"
REQUIRED_USE="^^ ( ${IUSE_KCONFIG/+} )"
PROVIDE="virtual/kernel"

DEPEND="sys-apps/debianutils
    initramfs? ( chromeos-base/chromeos-initramfs )"
RDEPEND=""

vmlinux_text_base=${CHROMEOS_U_BOOT_VMLINUX_TEXT_BASE:-0x20008000}

# Use a single or split kernel config as specified in the board or variant
# make.conf overlay. Default to the arch specific split config if an
# overlay or variant does not set either CHROMEOS_KERNEL_CONFIG or
# CHROMEOS_KERNEL_SPLITCONFIG. CHROMEOS_KERNEL_CONFIG is set relative
# to the root of the kernel source tree.

if [ -n "${CHROMEOS_KERNEL_CONFIG}" ]; then
	config="${S}/${CHROMEOS_KERNEL_CONFIG}"
else
	if [ "${ARCH}" = "x86" ]; then
		config=${CHROMEOS_KERNEL_SPLITCONFIG:-"chromeos-intel-menlow"}
	else
		config=${CHROMEOS_KERNEL_SPLITCONFIG:-"chromeos-${ARCH}"}
	fi
fi

# TODO(jglasgow) Need to fix DEPS file to get rid of "files"
CROS_WORKON_LOCALNAME="../third_party/kernel/files"

# This must be inherited *after* EGIT/CROS_WORKON variables defined
inherit cros-workon

# Allow override of kernel arch.
kernel_arch=${CHROMEOS_KERNEL_ARCH:-"$(tc-arch-kernel)"}

cross=${CHOST}-
COMPILER_OPTS=""
# Hack for using 64-bit kernel with 32-bit user-space
if [ "${ARCH}" = "x86" -a "${kernel_arch}" = "x86_64" ]; then
	cross=${CBUILD}-
else
	# TODO(raymes): Force GNU ld over gold. There are still some
	# gold issues to iron out. See: 13209.
	tc-export LD CC CXX
	COMPILER_OPTS="LD=\"$(get_binutils_path_ld)/ld\""
	COMPILER_OPTS+=" CC=\"${CC} -B$(get_binutils_path_ld)\""
	COMPILER_OPTS+=" CXX=\"${CXX} -B$(get_binutils_path_ld)\""
fi

build_dir="${S}/build/$(basename ${ROOT})"
build_cfg="${build_dir}/.config"

src_configure() {
	mkdir -p "${build_dir}"

	elog "Using kernel config: ${config}"

	if [ -n "${CHROMEOS_KERNEL_CONFIG}" ]; then
		cp -f "${config}" "${build_cfg}" || die
	else
		chromeos/scripts/prepareconfig ${config} || die
		mv .config "${build_cfg}"
	fi

	if use fbconsole; then
		elog "   - adding framebuffer console config"
		cat "${FILESDIR}"/fbconsole.config >> "${build_cfg}"
	fi

	if use nfs; then
		elog "   - adding NFS config"
		cat "${FILESDIR}"/nfs.config >> "${build_cfg}"
	fi

	# Use default for any options not explitly set in splitconfig
	yes "" | eval emake \
		${COMPILER_OPTS} \
		ARCH=${kernel_arch} \
		O="${build_dir}" \
		oldconfig || die
}

src_compile() {
	if use initramfs; then
		INITRAMFS="CONFIG_INITRAMFS_SOURCE=${ROOT}/usr/bin/initramfs.cpio.gz"
		# We want avoid copying modules into the initramfs so we need to enable
		# the functionality required for the initramfs here.

		# TPM support to ensure proper locking.
		INITRAMFS="$INITRAMFS CONFIG_TCG_TPM=y CONFIG_TCG_TIS=y"

		# VFAT FS support for EFI System Partition updates.
		INITRAMFS="$INITRAMFS CONFIG_NLS_CODEPAGE_437=y"
		INITRAMFS="$INITRAMFS CONFIG_NLS_ISO8859_1=y"
		INITRAMFS="$INITRAMFS CONFIG_FAT_FS=y CONFIG_VFAT_FS=y"
	else
		INITRAMFS=""
	fi
	eval emake ${COMPILER_OPTS} \
		$INITRAMFS \
		ARCH=${kernel_arch} \
		O="${build_dir}" \
		CROSS_COMPILE="${cross}" || die
}

src_install() {
	dodir boot

	eval emake ${COMPILER_OPTS} \
		ARCH=${kernel_arch}\
		CROSS_COMPILE="${cross}" \
		INSTALL_PATH="${D}/boot" \
		O="${build_dir}" \
		install || die

	eval emake ${COMPILER_OPTS} \
		ARCH=${kernel_arch}\
		CROSS_COMPILE="${cross}" \
		INSTALL_MOD_PATH="${D}" \
		O="${build_dir}" \
		modules_install || die

	eval emake ${COMPILER_OPTS} \
		ARCH=${kernel_arch}\
		CROSS_COMPILE="${cross}" \
		INSTALL_MOD_PATH="${D}" \
		O="${build_dir}" \
		firmware_install || die

	if [ "${ARCH}" = "arm" ]; then
		version=$(ls "${D}"/lib/modules)

		cp -a \
			"${build_dir}"/arch/"${ARCH}"/boot/zImage \
			"${D}/boot/vmlinuz-${version}" || die

		cp -a \
			"${build_dir}"/System.map \
			"${D}/boot/System.map-${version}" || die

		cp -a \
			"${build_dir}"/.config \
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

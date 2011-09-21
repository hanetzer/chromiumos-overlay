# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="386b8b2c382f51765e05706b25d09927e8a695e2"
CROS_WORKON_PROJECT="chromiumos/third_party/kernel"

inherit binutils-funcs cros-kernel toolchain-funcs

DESCRIPTION="Chrome OS Kernel"
HOMEPAGE="http://www.chromium.org/"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE_KCONFIG="+kconfig_generic kconfig_atom kconfig_atom64 kconfig_tegra2"
IUSE="-fbconsole -initramfs -nfs -blkdevram ${IUSE_KCONFIG} -device_tree"
IUSE="${IUSE} -pcserial -kernel_sources -systemtap +serial8250"
REQUIRED_USE="^^ ( ${IUSE_KCONFIG/+} )"
STRIP_MASK="/usr/lib/debug/boot/vmlinux"

DEPEND="sys-apps/debianutils
    chromeos-base/kernel-headers
    initramfs? ( chromeos-base/chromeos-initramfs )
    !sys-kernel/chromeos-kernel-next
"
RDEPEND="!sys-kernel/chromeos-kernel-next"

# TODO(vbendeb): we might need to be able to define the device tree source
# name by some other means or to override the default. For now it must match
# the name/board name.
dev_tree_base=${PKG_CONFIG#pkg-config-}

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
bin_dtb="${build_dir}/device-tree.dtb"
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

	if use blkdevram; then
		elog "   - adding ram block device config"
		cat "${FILESDIR}"/blkdevram.config >> "${build_cfg}"
	fi

	if use fbconsole; then
		elog "   - adding framebuffer console config"
		cat "${FILESDIR}"/fbconsole.config >> "${build_cfg}"
	fi

	if use nfs; then
		elog "   - adding NFS config"
		cat "${FILESDIR}"/nfs.config >> "${build_cfg}"
	fi
	if use systemtap; then
		elog "	- adding configs to support systemtap"
		cat "${FILESDIR}"/systemtap.config >> "${build_cfg}"
	fi
	if use serial8250; then
		elog "	- add configs of serial8250"
		cat "${FILESDIR}"/serial8250.config >> "${build_cfg}"
	fi

	if use pcserial; then
		elog "   - adding PC serial config"
		cat "${FILESDIR}"/pcserial.config >> "${build_cfg}"
	fi

	# Use default for any options not explitly set in splitconfig
	yes "" | eval emake \
		${COMPILER_OPTS} \
		ARCH=${kernel_arch} \
		O="${build_dir}" \
		oldconfig || die
}

src_compile() {

	if use arm; then
		build_targets='uImage  modules'
	else
		build_targets=  # use make default target
	fi

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
	eval emake ${COMPILER_OPTS} -k \
		$INITRAMFS \
		ARCH=${kernel_arch} \
		O="${build_dir}" \
		CROSS_COMPILE="${cross}" ${build_targets} || die

	if use device_tree; then
		dtc  -O dtb -p 500 -o "${bin_dtb}" \
		  "arch/arm/boot/dts/${dev_tree_base}.dts" || \
		  die 'Device tree compilation failed'
	fi
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

	if use arm; then
		local version=$(ls "${D}"/lib/modules)
		local boot_dir="${build_dir}/arch/${ARCH}/boot"
		local kernel_bin="${D}/boot/vmlinuz-${version}"
		local load_addr=0x03000000
		if use device_tree; then
			local its_script="${build_dir}/its_script"
			sed "s|%BUILD_ROOT%|${boot_dir}|;\
			     s|%DEV_TREE%|${bin_dtb}|; \
			     s|%LOAD_ADDR%|${load_addr}|;" \
			  "${FILESDIR}/kernel_fdt.its" > "${its_script}" || die
			mkimage  -f "${its_script}" "${kernel_bin}" || die
		else
			cp -a "${boot_dir}/uImage" "${kernel_bin}" || die
		fi

		# TODO(vbendeb): remove the below .uimg link creation code
		# after the build scripts have been modified to use the base
		# image name.
		cd $(dirname "${kernel_bin}")
		ln -sf $(basename "${kernel_bin}") vmlinux.uimg || die
	fi

	# Install uncompressed kernel for debugging purposes.
	dodir /usr/lib/debug/boot
	insinto /usr/lib/debug/boot
	doins "${build_dir}/vmlinux"

	if use kernel_sources; then
		install_kernel_sources
	fi
}

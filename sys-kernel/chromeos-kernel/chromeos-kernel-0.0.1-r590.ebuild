# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="0ddc1931523a579af6962358a01cbb45d525ae75"
CROS_WORKON_PROJECT="chromiumos/third_party/kernel"

inherit binutils-funcs cros-kernel toolchain-funcs

DESCRIPTION="Chrome OS Kernel"
HOMEPAGE="http://www.chromium.org/"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE_KCONFIG="+kconfig_generic kconfig_atom kconfig_atom64 kconfig_tegra2"
IUSE="-fbconsole -initramfs -nfs -blkdevram ${IUSE_KCONFIG} -device_tree"
IUSE="${IUSE} -pcserial -kernel_sources -systemtap +serial8250 -highmem"
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

# TODO(jglasgow) Need to fix DEPS file to get rid of "files"
CROS_WORKON_LOCALNAME="../third_party/kernel/files"

# This must be inherited *after* EGIT/CROS_WORKON variables defined
inherit cros-workon

build_dir="${S}/build/$(basename ${ROOT})"
bin_dtb="${build_dir}/device-tree.dtb"
build_cfg="${build_dir}/.config"

kmake() {
	# Allow override of kernel arch.
	local kernel_arch=${CHROMEOS_KERNEL_ARCH:-$(tc-arch-kernel)}

	local cross=${CHOST}-
	# Hack for using 64-bit kernel with 32-bit user-space
	if [ "${ARCH}" = "x86" -a "${kernel_arch}" = "x86_64" ]; then
		cross=${CBUILD}-
	else
		# TODO(raymes): Force GNU ld over gold. There are still some
		# gold issues to iron out. See: 13209.
		tc-export LD CC CXX

		set -- \
			LD="$(get_binutils_path_ld)/ld" \
			CC="${CC} -B$(get_binutils_path_ld)" \
			CXX="${CXX} -B$(get_binutils_path_ld)" \
			"$@"
	fi

	emake \
		ARCH=${kernel_arch} \
		LDFLAGS="$(raw-ldflags)" \
		CROSS_COMPILE="${cross}" \
		O="${build_dir}" \
		"$@"
}

# use_config <USE flag> <helpful message> [config file name in $FILESDIR]
# If you don't specify the config file name, we'll assume one exists
# with the same name as the USE flag.
use_config() {
	local flag="$1" msg="$2" frag="${3:-$1}"
	if use ${flag}; then
		elog "   - adding ${msg} config"
		cat "${FILESDIR}"/${frag}.config >> "${build_cfg}"
	fi
}

src_configure() {
	mkdir -p "${build_dir}"

	# Use a single or split kernel config as specified in the board or variant
	# make.conf overlay. Default to the arch specific split config if an
	# overlay or variant does not set either CHROMEOS_KERNEL_CONFIG or
	# CHROMEOS_KERNEL_SPLITCONFIG. CHROMEOS_KERNEL_CONFIG is set relative
	# to the root of the kernel source tree.
	local config
	if [ -n "${CHROMEOS_KERNEL_CONFIG}" ]; then
		config="${S}/${CHROMEOS_KERNEL_CONFIG}"
	else
		if [ "${ARCH}" = "x86" ]; then
			config=${CHROMEOS_KERNEL_SPLITCONFIG:-"chromeos-intel-menlow"}
		else
			config=${CHROMEOS_KERNEL_SPLITCONFIG:-"chromeos-${ARCH}"}
		fi
	fi

	elog "Using kernel config: ${config}"

	if [ -n "${CHROMEOS_KERNEL_CONFIG}" ]; then
		cp -f "${config}" "${build_cfg}" || die
	else
		chromeos/scripts/prepareconfig ${config} || die
		mv .config "${build_cfg}"
	fi

	use_config blkdevram "ram block device"
	use_config fbconsole "framebuffer console"
	use_config nfs "NFS"
	use_config systemtap "systemtap support"
	use_config serial8250 "serial8250"
	use_config pcserial "PC serial"
	use_config highmem "highmem"

	# Use default for any options not explitly set in splitconfig
	yes "" | kmake oldconfig
}

src_compile() {
	local build_targets=  # use make default target
	if use arm; then
		build_targets="uImage modules"
	fi

	local INITRAMFS=""
	if use initramfs; then
		INITRAMFS="CONFIG_INITRAMFS_SOURCE=${ROOT}/usr/bin/initramfs.cpio.gz"
		# We want to avoid copying modules into the initramfs so we need
		# to enable the functionality required for the initramfs here.

		# TPM support to ensure proper locking.
		INITRAMFS+=" CONFIG_TCG_TPM=y CONFIG_TCG_TIS=y"

		# VFAT FS support for EFI System Partition updates.
		INITRAMFS+=" CONFIG_NLS_CODEPAGE_437=y"
		INITRAMFS+=" CONFIG_NLS_ISO8859_1=y"
		INITRAMFS+=" CONFIG_FAT_FS=y CONFIG_VFAT_FS=y"
	fi
	kmake -k \
		${INITRAMFS} \
		${build_targets}

	if use device_tree; then
		dtc -O dtb -p 500 -o "${bin_dtb}" \
			"arch/arm/boot/dts/${dev_tree_base}.dts" \
			|| die 'Device tree compilation failed'
	fi
}

src_install() {
	dodir /boot
	kmake INSTALL_PATH="${D}/boot" install
	kmake INSTALL_MOD_PATH="${D}" modules_install
	kmake INSTALL_MOD_PATH="${D}" firmware_install

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
	insinto /usr/lib/debug/boot
	doins "${build_dir}/vmlinux"

	if use kernel_sources; then
		install_kernel_sources
	fi
}

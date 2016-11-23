# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# Check for EAPI 4+
case "${EAPI:-0}" in
4|5|6) ;;
*) die "unsupported EAPI (${EAPI}) in eclass (${ECLASS})" ;;
esac

# Since we use CHROMEOS_KERNEL_CONFIG and CHROMEOS_KERNEL_SPLITCONFIG here,
# it is not safe to reuse the kernel prebuilts across different boards. Inherit
# the cros-board eclass to make sure that doesn't happen.
inherit binutils-funcs cros-board linux-info toolchain-funcs versionator

HOMEPAGE="http://www.chromium.org/"
LICENSE="GPL-2"
SLOT="0"

DEPEND="sys-apps/debianutils
	sys-kernel/linux-firmware
	factory_netboot_ramfs? ( chromeos-base/chromeos-initramfs[factory_netboot_ramfs] )
	factory_shim_ramfs? ( chromeos-base/chromeos-initramfs[factory_shim_ramfs] )
	loader_kernel_ramfs? ( chromeos-base/chromeos-initramfs[loader_kernel_ramfs] )
	recovery_ramfs? ( chromeos-base/chromeos-initramfs[recovery_ramfs] )
	builtin_fw_t210_nouveau? ( sys-kernel/nouveau-firmware )
	builtin_fw_t210_bpmp? ( sys-kernel/tegra_bpmp-t210 )
"

WIRELESS_VERSIONS=( 3.4 3.8 3.16 3.18 4.2 )
WIRELESS_SUFFIXES=( ${WIRELESS_VERSIONS[@]/.} )

IUSE="
	-device_tree
	+firmware_install
	-kernel_sources
	nfc
	${WIRELESS_SUFFIXES[@]/#/-wireless}
	-wifi_testbed_ap
	-boot_dts_device_tree
	-wifi_debug
	-nowerror
	-ppp
	-lxc
	-binder
	-selinux_develop
	-transparent_hugepage
	tpm2
"
STRIP_MASK="/usr/lib/debug/boot/vmlinux"

# Ignore files under /lib/modules/ as we like to install vdso objects in there.
MULTILIB_STRICT_EXEMPT+="|modules"

# Build out-of-tree and incremental by default, but allow an ebuild inheriting
# this eclass to explicitly build in-tree.
: ${CROS_WORKON_OUTOFTREE_BUILD:=1}
: ${CROS_WORKON_INCREMENTAL_BUILD:=1}

# Config fragments selected by USE flags. _config fragments are mandatory,
# _config_disable fragments are optional and will be appended to kernel config
# if use flag is not set.
# ...fragments will have the following variables substitutions
# applied later (needs to be done later since these values
# aren't reliable when used in a global context like this):
#   %ROOT% => ${ROOT}

CONFIG_FRAGMENTS=(
	acpi_ac_off
	allocator_slab
	binder
	blkdevram
	ca0132
	cifs
	cros_ec_mec
	debug
	dm_snapshot
	dwc2_dual_role
	dyndebug
	fbconsole
	factory_netboot_ramfs
	factory_shim_ramfs
	gdmwimax
	gobi
	highmem
	i2cdev
	iscsi
	kasan
	kcov
	kgdb
	kvm
	loader_kernel_ramfs
	lockdebug
	lxc
	mbim
	nfc
	nfs
	nowerror
	pcserial
	ppp
	qmi
	realtekpstor
	recovery_ramfs
	samsung_serial
	selinux_develop
	socketmon
	systemtap
	tpm
	transparent_hugepage
	usb_gadget
	usb_gadget_acm
	usb_gadget_audio
	usb_gadget_ncm
	vfat
	video_cards_amdgpu
	vlan
	vtconsole
	wifi_testbed_ap
	wifi_debug
	wifi_diag
	wireless34
	x32
)

acpi_ac_off_desc="Turn off ACPI AC"
acpi_ac_off_config="
# CONFIG_ACPI_AC is not set
"

allocator_slab_desc="Turn on SLAB allocator"
allocator_slab_config="
CONFIG_SLAB=y
CONFIG_SLUB=n
"

binder_desc="binder IPC"
binder_config="
CONFIG_ANDROID=y
CONFIG_ANDROID_BINDER_IPC=y
"

blkdevram_desc="ram block device"
blkdevram_config="
CONFIG_BLK_DEV_RAM=y
CONFIG_BLK_DEV_RAM_COUNT=16
CONFIG_BLK_DEV_RAM_SIZE=16384
"

ca0132_desc="CA0132 ALSA codec"
ca0132_config="
CONFIG_SND_HDA_CODEC_CA0132=y
CONFIG_SND_HDA_DSP_LOADER=y
"

cifs_desc="Samba/CIFS Support"
cifs_config="
CONFIG_CIFS=m
"

cros_ec_mec_desc="LPC Support for Microchip Embedded Controller"
cros_ec_mec_config="
CONFIG_MFD_CROS_EC_LPC_MEC=y
CONFIG_CROS_EC_LPC_MEC=y
"

dm_snapshot_desc="Snapshot device mapper target"
dm_snapshot_config="
CONFIG_BLK_DEV_DM=y
CONFIG_DM_SNAPSHOT=m
"

dwc2_dual_role_desc="Dual Role support for DesignWare USB2.0 controller"
dwc2_dual_role_config="
CONFIG_USB_DWC2_DUAL_ROLE=y
"

dyndebug_desc="Enable Dynamic Debug"
dyndebug_config="
CONFIG_DYNAMIC_DEBUG=y
"

fbconsole_desc="framebuffer console"
fbconsole_config="
CONFIG_FRAMEBUFFER_CONSOLE=y
"
fbconsole_config_disable="
CONFIG_FRAMEBUFFER_CONSOLE=n
"

gdmwimax_desc="GCT GDM72xx WiMAX support"
gdmwimax_config="
CONFIG_WIMAX_GDM72XX=m
CONFIG_WIMAX_GDM72XX_USB=y
CONFIG_WIMAX_GDM72XX_USB_PM=y
"

gobi_desc="Qualcomm Gobi modem driver"
gobi_config="
CONFIG_USB_NET_GOBI=m
"

highmem_desc="highmem"
highmem_config="
CONFIG_HIGHMEM64G=y
"

i2cdev_desc="I2C device interface"
i2cdev_config="
CONFIG_I2C_CHARDEV=y
"

iscsi_desc="iSCSI initiator and target drivers"
iscsi_config="
CONFIG_SCSI_LOWLEVEL=y
CONFIG_ISCSI_TCP=m
CONFIG_CONFIGFS_FS=m
CONFIG_TARGET_CORE=m
CONFIG_ISCSI_TARGET=m
CONFIG_TCM_IBLOCK=m
CONFIG_TCM_FILEIO=m
CONFIG_TCM_PSCSI=m
"

debug_desc="Miscellaneous debug extensions"
debug_config="
CONFIG_DRM_POWERVR_ROGUE_DEBUG=y
"

kasan_desc="Enable KASAN"
kasan_config="
CONFIG_KASAN=y
CONFIG_KASAN_INLINE=y
CONFIG_TEST_KASAN=m
CONFIG_SLUB_DEBUG=y
CONFIG_SLUB_DEBUG_ON=y
"

kcov_desc="Enable kcov"
kcov_config="
CONFIG_KCOV=y
# CONFIG_RANDOMIZE_BASE is not set
"

kgdb_desc="Enable kgdb"
kgdb_config="
CONFIG_DEBUG_KERNEL=y
CONFIG_DEBUG_INFO=y
CONFIG_FRAME_POINTER=y
CONFIG_KGDB=y
CONFIG_KGDB_KDB=y
# CONFIG_RANDOMIZE_BASE is not set
# CONFIG_WATCHDOG is not set
CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=1
"""

lockdebug_desc="Additional lock debug settings"
lockdebug_config="
CONFIG_DEBUG_RT_MUTEXES=y
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
CONFIG_PROVE_RCU=y
CONFIG_PROVE_LOCKING=y
CONFIG_DEBUG_ATOMIC_SLEEP=y
"

nfc_desc="Enable NFC support"
nfc_config="
CONFIG_NFC=m
CONFIG_NFC_HCI=m
CONFIG_NFC_LLCP=y
CONFIG_NFC_NCI=m
CONFIG_NFC_PN533=m
CONFIG_NFC_PN544=m
CONFIG_NFC_PN544_I2C=m
CONFIG_NFC_SHDLC=y
"

tpm_desc="TPM support"
tpm_config="
CONFIG_TCG_TPM=y
CONFIG_TCG_TIS=y
"

recovery_ramfs_desc="Initramfs for recovery image"
recovery_ramfs_config='
CONFIG_INITRAMFS_SOURCE="%ROOT%/var/lib/initramfs/recovery_ramfs.cpio.xz"
CONFIG_INITRAMFS_COMPRESSION_XZ=y
'

loader_kernel_ramfs_desc="Initramfs for loader kernel"
loader_kernel_ramfs_config='
CONFIG_INITRAMFS_SOURCE="%ROOT%/var/lib/initramfs/loader_kernel_ramfs.cpio.xz"
CONFIG_INITRAMFS_COMPRESSION_XZ=y
CONFIG_KEXEC=y
'

factory_netboot_ramfs_desc="Initramfs for factory netboot installer"
factory_netboot_ramfs_config='
CONFIG_INITRAMFS_SOURCE="%ROOT%/var/lib/initramfs/factory_netboot_ramfs.cpio.xz"
CONFIG_INITRAMFS_COMPRESSION_XZ=y
'

factory_shim_ramfs_desc="Initramfs for factory installer shim"
factory_shim_ramfs_config='
CONFIG_INITRAMFS_SOURCE="%ROOT%/var/lib/initramfs/factory_shim_ramfs.cpio.xz"
CONFIG_INITRAMFS_COMPRESSION_XZ=y
'

vfat_desc="vfat"
vfat_config="
CONFIG_NLS_CODEPAGE_437=y
CONFIG_NLS_ISO8859_1=y
CONFIG_FAT_FS=y
CONFIG_VFAT_FS=y
"

kvm_desc="KVM"
kvm_config="
CONFIG_HAVE_KVM=y
CONFIG_HAVE_KVM_IRQCHIP=y
CONFIG_HAVE_KVM_EVENTFD=y
CONFIG_KVM_APIC_ARCHITECTURE=y
CONFIG_KVM_MMIO=y
CONFIG_KVM_ASYNC_PF=y
CONFIG_KVM=m
CONFIG_KVM_INTEL=m
# CONFIG_KVM_AMD is not set
# CONFIG_KVM_MMU_AUDIT is not set
CONFIG_VIRTIO=m
CONFIG_VIRTIO_BLK=m
CONFIG_VIRTIO_NET=m
CONFIG_VIRTIO_CONSOLE=m
CONFIG_VIRTIO_RING=m
CONFIG_VIRTIO_PCI=m
"

# TODO(benchan): Remove the 'mbim' use flag and unconditionally enable the
# CDC MBIM driver once Chromium OS fully supports MBIM.
mbim_desc="CDC MBIM driver"
mbim_config="
CONFIG_USB_NET_CDC_MBIM=m
"

nfs_desc="NFS"
nfs_config="
CONFIG_USB_NET_AX8817X=y
CONFIG_DNOTIFY=y
CONFIG_DNS_RESOLVER=y
CONFIG_LOCKD=y
CONFIG_LOCKD_V4=y
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NFSD=m
CONFIG_NFSD_V3=y
CONFIG_NFSD_V4=y
CONFIG_NFS_COMMON=y
CONFIG_NFS_FS=y
CONFIG_NFS_USE_KERNEL_DNS=y
CONFIG_NFS_V3=y
CONFIG_NFS_V4=y
CONFIG_ROOT_NFS=y
CONFIG_RPCSEC_GSS_KRB5=y
CONFIG_SUNRPC=y
CONFIG_SUNRPC_GSS=y
CONFIG_USB_USBNET=y
CONFIG_IP_PNP=y
CONFIG_IP_PNP_DHCP=y
"

pcserial_desc="PC serial"
pcserial_config="
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_SERIAL_8250_DW=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_PARPORT=y
CONFIG_PARPORT_PC=y
CONFIG_PARPORT_SERIAL=y
"

ppp_desc="PPPoE and ppp support"
ppp_config="
CONFIG_PPPOE=m
CONFIG_PPP=m
CONFIG_PPP_BSDCOMP=m
CONFIG_PPP_DEFLATE=m
CONFIG_PPP_MPPE=m
CONFIG_PPP_SYNC_TTY=m
"

qmi_desc="QMI WWAN driver"
qmi_config="
CONFIG_USB_NET_QMI_WWAN=m
"

realtekpstor_desc="Realtek PCI card reader"
realtekpstor_config="
CONFIG_RTS_PSTOR=m
"

samsung_serial_desc="Samsung serialport"
samsung_serial_config="
CONFIG_SERIAL_SAMSUNG=y
CONFIG_SERIAL_SAMSUNG_CONSOLE=y
"

selinux_develop_desc="SELinux developer mode"
selinux_develop_config="
CONFIG_SECURITY_SELINUX_DEVELOP=y
"

socketmon_desc="INET socket monitoring interface (for iproute2 ss)"
socketmon_config="
CONFIG_INET_DIAG=y
CONFIG_INET_TCP_DIAG=y
CONFIG_INET_UDP_DIAG=y
"

systemtap_desc="systemtap support"
systemtap_config="
CONFIG_KPROBES=y
CONFIG_DEBUG_INFO=y
"

usb_gadget_desc="USB gadget support with ConfigFS/FunctionFS"
usb_gadget_config="
CONFIG_USB_CONFIGFS=m
CONFIG_USB_CONFIGFS_F_FS=y
CONFIG_USB_FUNCTIONFS=m
CONFIG_USB_GADGET=y
"

usb_gadget_acm_desc="USB ACM gadget support"
usb_gadget_acm_config="
CONFIG_USB_CONFIGFS_ACM=y
"

usb_gadget_audio_desc="USB Audio gadget support"
usb_gadget_audio_config="
CONFIG_USB_CONFIGFS_F_UAC1=y
CONFIG_USB_CONFIGFS_F_UAC2=y
"

usb_gadget_ncm_desc="USB NCM gadget support"
usb_gadget_ncm_config="
CONFIG_USB_CONFIGFS_NCM=y
"

video_cards_amdgpu_desc="AMDGPU driver"
video_cards_amdgpu_config="
CONFIG_DRM_AMDGPU=y
"

vlan_desc="802.1Q VLAN"
vlan_config="
CONFIG_VLAN_8021Q=m
"

wifi_testbed_ap_desc="Defer ath9k EEPROM regulatory"
wifi_testbed_ap_warning="
Don't use the wifi_testbed_ap flag unless you know what you are doing!
An image built with this flag set must never be run outside a
sealed RF chamber!
"
wifi_testbed_ap_config="
CONFIG_ATH_DEFER_EEPROM_REGULATORY=y
CONFIG_BRIDGE=y
CONFIG_MAC80211_BEACON_FOOTER=y
"

wifi_debug_desc="Enable extra debug flags for WiFi"
wifi_debug_config="
CONFIG_IWL7000_XVT=m
"

wifi_diag_desc="mac80211 WiFi diagnostic support"
wifi_diag_config="
CONFIG_MAC80211_WIFI_DIAG=y
"

x32_desc="x32 ABI support"
x32_config="
CONFIG_X86_X32=y
"

wireless34_desc="Wireless 3.4 stack"
wireless34_config="
CONFIG_ATH9K_BTCOEX=m
CONFIG_ATH9K_BTCOEX_COMMON=m
CONFIG_ATH9K_BTCOEX_HW=m
"

vtconsole_desc="VT console"
vtconsole_config="
CONFIG_VT=y
CONFIG_VT_CONSOLE=y
"
vtconsole_config_disable="
CONFIG_VT=n
CONFIG_VT_CONSOLE=n
"

nowerror_desc="Don't build with -Werror (warnings aren't fatal)."
nowerror_config="
CONFIG_ERROR_ON_WARNING=n
"

lxc_desc="LXC Support (Linux Containers)"
lxc_config="
CONFIG_CGROUP_DEVICE=y
CONFIG_CPUSETS=y
CONFIG_CGROUP_CPUACCT=y
CONFIG_RESOURCE_COUNTERS=y
CONFIG_DEVPTS_MULTIPLE_INSTANCES=y
CONFIG_MACVLAN=y
CONFIG_POSIX_MQUEUE=y
CONFIG_BRIDGE_NETFILTER=y
"

transparent_hugepage_desc="Transparent Hugepage Support"
transparent_hugepage_config="
CONFIG_TRANSPARENT_HUGEPAGE=y
CONFIG_TRANSPARENT_HUGEPAGE_MADVISE=y
"
# Firmware binaries selected by USE flags.  Selected firmware binaries will
# be built into the kernel using CONFIG_EXTRA_FIRMWARE.

FIRMWARE_BINARIES=(
	builtin_fw_amdgpu
	builtin_fw_t124_xusb
	builtin_fw_t210_xusb
	builtin_fw_t210_nouveau
	builtin_fw_t210_bpmp
)

builtin_fw_amdgpu_desc="Firmware for AMD GPU"
builtin_fw_amdgpu_files=(
	amdgpu/carrizo_ce.bin
	amdgpu/carrizo_me.bin
	amdgpu/carrizo_mec.bin
	amdgpu/carrizo_mec2.bin
	amdgpu/carrizo_pfp.bin
	amdgpu/carrizo_rlc.bin
	amdgpu/carrizo_sdma.bin
	amdgpu/carrizo_sdma1.bin
	amdgpu/carrizo_uvd.bin
	amdgpu/carrizo_vce.bin
	amdgpu/stoney_ce.bin
	amdgpu/stoney_me.bin
	amdgpu/stoney_mec.bin
	amdgpu/stoney_pfp.bin
	amdgpu/stoney_rlc.bin
	amdgpu/stoney_sdma.bin
	amdgpu/stoney_uvd.bin
	amdgpu/stoney_vce.bin
)

builtin_fw_t124_xusb_desc="Tegra124 XHCI controller"
builtin_fw_t124_xusb_files=(
	nvidia/tegra124/xusb.bin
)

builtin_fw_t210_xusb_desc="Tegra210 XHCI controller"
builtin_fw_t210_xusb_files=(
	nvidia/tegra210/xusb.bin
)

builtin_fw_t210_nouveau_desc="Tegra210 Nouveau GPU"
builtin_fw_t210_nouveau_files=(
	nouveau/acr_ucode.bin
	nouveau/fecs.bin
	nouveau/fecs_sig.bin
	nouveau/gpmu_ucode_desc.bin
	nouveau/gpmu_ucode_image.bin
	nouveau/nv12b_bundle
	nouveau/nv12b_fuc409c
	nouveau/nv12b_fuc409d
	nouveau/nv12b_fuc41ac
	nouveau/nv12b_fuc41ad
	nouveau/nv12b_method
	nouveau/nv12b_sw_ctx
	nouveau/nv12b_sw_nonctx
	nouveau/pmu_bl.bin
	nouveau/pmu_sig.bin
)

builtin_fw_t210_bpmp_desc="Tegra210 BPMP"
builtin_fw_t210_bpmp_files=(
	nvidia/tegra210/bpmp.bin
)

extra_fw_config="
CONFIG_EXTRA_FIRMWARE=\"%FW%\"
CONFIG_EXTRA_FIRMWARE_DIR=\"%ROOT%/lib/firmware\"
"

# Add all config and firmware fragments as off by default
IUSE="${IUSE} ${CONFIG_FRAGMENTS[@]} ${FIRMWARE_BINARIES[@]}"
REQUIRED_USE="
	factory_netboot_ramfs? ( !recovery_ramfs !factory_shim_ramfs )
	factory_shim_ramfs? ( !recovery_ramfs !factory_netboot_ramfs )
	recovery_ramfs? ( !factory_netboot_ramfs !factory_shim_ramfs )
	factory_netboot_ramfs? ( i2cdev )
	factory_shim_ramfs? ( i2cdev )
	recovery_ramfs? ( i2cdev )
	factory_netboot_ramfs? ( || ( tpm tpm2 ) )
	factory_shim_ramfs? ( || ( tpm tpm2 ) )
	recovery_ramfs? ( || ( tpm tpm2 ) )
"

# If an overlay has eclass overrides, but doesn't actually override this
# eclass, we'll have ECLASSDIR pointing to the active overlay's
# eclass/ dir, but this eclass is still in the main chromiumos tree.  So
# add a check to locate the cros-kernel/ regardless of what's going on.
ECLASSDIR_LOCAL=${BASH_SOURCE[0]%/*}
defconfig_dir() {
	local d="${ECLASSDIR}/cros-kernel"
	if [[ ! -d ${d} ]] ; then
		d="${ECLASSDIR_LOCAL}/cros-kernel"
	fi
	echo "${d}"
}

# @FUNCTION: kernelrelease
# @DESCRIPTION:
# Returns the current compiled kernel version.
# Note: Only valid after src_configure has finished running.
kernelrelease() {
	kmake -s --no-print-directory kernelrelease
}

# @FUNCTION: install_kernel_sources
# @DESCRIPTION:
# Installs the kernel sources into ${D}/usr/src/${P} and fixes symlinks.
# The package must have already installed a directory under ${D}/lib/modules.
install_kernel_sources() {
	local version=$(kernelrelease)
	local dest_modules_dir=lib/modules/${version}
	local dest_source_dir=usr/src/${P}
	local dest_build_dir=${dest_source_dir}/build

	# Fix symlinks in lib/modules
	ln -sfvT "../../../${dest_build_dir}" \
	   "${D}/${dest_modules_dir}/build" || die
	ln -sfvT "../../../${dest_source_dir}" \
	   "${D}/${dest_modules_dir}/source" || die

	einfo "Installing kernel source tree"
	dodir "${dest_source_dir}"
	local f
	for f in "${S}"/*; do
		[[ "$f" == "${S}/build" ]] && continue
		cp -pPR "${f}" "${D}/${dest_source_dir}" ||
			die "Failed to copy kernel source tree"
	done

	dosym "${P}" "/usr/src/linux"

	einfo "Installing kernel build tree"
	dodir "${dest_build_dir}"
	cp -pPR "$(cros-workon_get_build_dir)"/. "${D}/${dest_build_dir}" || die

	# Modify Makefile to use the ROOT environment variable if defined.
	# This path needs to be absolute so that the build directory will
	# still work if copied elsewhere.
	sed -i -e "s@${S}@\$(ROOT)/${dest_source_dir}@" \
		"${D}/${dest_build_dir}/Makefile" || die
}

get_build_cfg() {
	echo "$(cros-workon_get_build_dir)/.config"
}

get_build_arch() {
	if [ "${ARCH}" = "arm" ] ; then
		case "${CHROMEOS_KERNEL_SPLITCONFIG}" in
			*exynos*)
				echo "exynos5"
				;;
			*rockchip64*)
				echo "rockchip64"
				;;
			*rockchip*)
				echo "rockchip"
				;;
			*tegra*)
				echo "tegra"
				;;
			*)
				echo "arm"
				;;
		esac
	elif [ "${ARCH}" = "x86" ] ; then
		case "${CHROMEOS_KERNEL_SPLITCONFIG}" in
			*i386*)
				echo "i386"
				;;
			*x86_64*)
				echo "x86_64"
				;;
			*)
				echo "x86"
				;;
		esac
	elif [ "${ARCH}" = "mips" ] ; then
		case "${CHROMEOS_KERNEL_SPLITCONFIG}" in
			*pistachio*)
				echo "pistachio"
				;;
			*)
				echo "maltasmvp"
				;;
		esac
	else
		tc-arch-kernel
	fi
}

# @FUNCTION: cros_chkconfig_present
# @USAGE: <option to check config for>
# @DESCRIPTION:
# Returns success of the provided option is present in the build config.
cros_chkconfig_present() {
	local config=$1
	grep -q "^CONFIG_$1=[ym]$" "$(get_build_cfg)"
}

cros-kernel2_pkg_setup() {
	# This is needed for running src_test().  The kernel code will need to
	# be rebuilt with `make check`.  If incremental build were enabled,
	# `make check` would have nothing left to build.
	use test && export CROS_WORKON_INCREMENTAL_BUILD=0
	cros-workon_pkg_setup
	linux-info_pkg_setup
}

# @FUNCTION: emit_its_script
# @USAGE: <output file> <kernel_dir> <device trees>
# @DESCRIPTION:
# Emits the its script used to build the u-boot fitImage kernel binary
# that contains the kernel as well as device trees used when booting
# it.

emit_its_script() {
	local kernel_arch=${CHROMEOS_KERNEL_ARCH:-$(tc-arch-kernel)}
	local image_name
	local iter=1
	local compression="none"
	local its_out=${1}
	shift
	local kernel_path=${1}
	shift

	case ${kernel_arch} in
		arm64)
			image_name="arch/${kernel_arch}/boot/Image"
			compression="lz4"
			;;
		mips)
			image_name="vmlinuz.bin"
			;;
		*)
			image_name="arch/${kernel_arch}/boot/zImage"
			;;
	esac

	if [[ "${compression}" == "lzma" ]]; then
		lzma -9 -z -f -k "${kernel_path}/${image_name}" || die
		image_name="${image_name}.lzma"
	elif [[ "${compression}" == "lz4" ]]; then
		lz4 -20 -z -f "${kernel_path}/${image_name}" || die
		image_name="${image_name}.lz4"
	fi

	cat > "${its_out}" <<-EOF || die
	/dts-v1/;

	/ {
		description = "Chrome OS kernel image with one or more FDT blobs";
		#address-cells = <1>;

		images {
			kernel@1 {
				data = /incbin/("${kernel_path}/${image_name}");
				type = "kernel_noload";
				arch = "${kernel_arch}";
				os = "linux";
				compression = "${compression}";
				load = <0>;
				entry = <0>;
			};
	EOF

	local dtb
	for dtb in "$@" ; do
		cat >> "${its_out}" <<-EOF || die
			fdt@${iter} {
				description = "$(basename ${dtb})";
				data = /incbin/("${dtb}");
				type = "flat_dt";
				arch = "${kernel_arch}";
				compression = "none";
				hash@1 {
					algo = "sha1";
				};
			};
		EOF
		((++iter))
	done

	cat <<-EOF >>"${its_out}"
		};
		configurations {
			default = "conf@1";
	EOF

	local i
	for i in $(seq 1 $((iter-1))) ; do
		cat >> "${its_out}" <<-EOF || die
			conf@${i} {
				kernel = "kernel@1";
				fdt = "fdt@${i}";
			};
		EOF
	done

	echo "	};" >> "${its_out}"
	echo "};" >> "${its_out}"
}

kmake() {
	local wifi_version
	local v
	for v in ${WIRELESS_VERSIONS[@]}; do
		if use wireless${v/.} ; then
			[ -n "${wifi_version}" ] &&
				die "Wireless ${v} AND ${wifi_version} both set"
			wifi_version=${v}
			set -- "$@" WIFIVERSION="-${v}"
		fi
	done

	# Allow override of kernel arch.
	local kernel_arch=${CHROMEOS_KERNEL_ARCH:-$(tc-arch-kernel)}

	# Support 64bit kernels w/32bit userlands.
	local cross=${CHOST}
	case ${ARCH}:${kernel_arch} in
		x86:x86_64)
			cross="x86_64-cros-linux-gnu"
			;;
		arm:arm64)
			cross="aarch64-cros-linux-gnu"
			;;
	esac

	if [[ "${CHOST}" != "${cross}" ]]; then
		ewarn "Resetting CC CXX LD STRIP OBJCOPY."
		unset CC CXX LD STRIP OBJCOPY
	fi

	CHOST=${cross} tc-export CC CXX LD STRIP OBJCOPY
	local binutils_path=$(LD=${cross}-ld get_binutils_path_ld)

	set -- \
		LD="${binutils_path}/ld $(usex x32 '-m elf_x86_64' '')" \
		CC="${CC} -B${binutils_path}" \
		CXX="${CXX} -B${binutils_path}" \
		"$@"

	cw_emake \
		ARCH=${kernel_arch} \
		LDFLAGS="$(raw-ldflags)" \
		CROSS_COMPILE="${cross}-" \
		O="$(cros-workon_get_build_dir)" \
		"$@"
}

cros-kernel2_src_prepare() {
	cros_use_gcc
	cros-workon_src_prepare
}

cros-kernel2_src_configure() {
	# Use a single or split kernel config as specified in the board or variant
	# make.conf overlay. Default to the arch specific split config if an
	# overlay or variant does not set either CHROMEOS_KERNEL_CONFIG or
	# CHROMEOS_KERNEL_SPLITCONFIG. CHROMEOS_KERNEL_CONFIG is set relative
	# to the root of the kernel source tree.
	local config
	local cfgarch="$(get_build_arch)"

	if [ -n "${CHROMEOS_KERNEL_CONFIG}" ]; then
		case ${CHROMEOS_KERNEL_CONFIG} in
			/*)
				config="${CHROMEOS_KERNEL_CONFIG}"
				;;
			*)
				config="${S}/${CHROMEOS_KERNEL_CONFIG}"
				;;
		esac
	else
		config=${CHROMEOS_KERNEL_SPLITCONFIG:-"chromiumos-${cfgarch}"}
	fi

	elog "Using kernel config: ${config}"

	# Keep a handle on the old .config in case it hasn't changed.  This way
	# we can keep the old timestamp which will avoid regenerating stuff that
	# hasn't actually changed.
	local temp_config="${T}/old-kernel-config"
	if [[ -e $(get_build_cfg) ]] ; then
		cp -a "$(get_build_cfg)" "${temp_config}"
	else
		rm -f "${temp_config}"
	fi

	if [ -n "${CHROMEOS_KERNEL_CONFIG}" ]; then
		cp -f "${config}" "$(get_build_cfg)" || die
	else
		if [ -e chromeos/scripts/prepareconfig ] ; then
			chromeos/scripts/prepareconfig ${config} \
				"$(get_build_cfg)" || die
		else
			config="$(defconfig_dir)/${cfgarch}_defconfig"
			ewarn "Can't prepareconfig, falling back to default " \
				"${config}"
			cp "${config}" "$(get_build_cfg)" || die
		fi
	fi

	local fragment
	for fragment in ${CONFIG_FRAGMENTS[@]}; do
		local config="${fragment}_config"
		local status

		if [[ ${!config+set} != "set" ]]; then
			die "'${fragment}' listed in CONFIG_FRAGMENTS, but ${config} is not set up"
		fi

		if use ${fragment}; then
			status="enabling"
		else
			config="${fragment}_config_disable"
			status="disabling"
			if [[ -z "${!config}" ]]; then
				continue
			fi
		fi

		local msg="${fragment}_desc"
		elog "   - ${status} ${!msg} config"
		local warning="${fragment}_warning"
		local warning_msg="${!warning}"
		if [[ -n "${warning_msg}" ]] ; then
			ewarn "${warning_msg}"
		fi

		echo "${!config}" | \
			sed -e "s|%ROOT%|${ROOT}|g" \
			>> "$(get_build_cfg)" || die
	done

	local -a builtin_fw
	for fragment in "${FIRMWARE_BINARIES[@]}"; do
		local files="${fragment}_files[@]"

		if [[ ${!files+set} != "set" ]]; then
			die "'${fragment}' listed in FIRMWARE_BINARIES, but ${files} is not set up"
		fi

		if use ${fragment}; then
			local msg="${fragment}_desc"
			elog "   - Embedding ${!msg} firmware"
			builtin_fw+=( "${!files}" )
		fi
	done

	if [[ ${#builtin_fw[@]} -gt 0 ]]; then
		echo "${extra_fw_config}" | \
			sed -e "s|%ROOT%|${ROOT}|g" -e "s|%FW%|${builtin_fw[*]}|g" \
			>> "$(get_build_cfg)" || die
	fi

	# Use default for any options not explitly set in splitconfig
	# Note: oldnoconfig is a misleading name -- it picks the default
	# value for new options, not 'n'.
	kmake oldnoconfig

	# Restore the old config if it is unchanged.
	if cmp -s "$(get_build_cfg)" "${temp_config}" ; then
		touch -r "${temp_config}" "$(get_build_cfg)"
	fi

	# Create .scmversion file so that kernel release version
	# doesn't include git hash for cros worked on builds.
	if [[ "${PV}" == "9999" ]]; then
		touch "$(cros-workon_get_build_dir)/.scmversion"
	fi
}

# @FUNCTION: get_dtb_name
# @USAGE: <dtb_dir>
# @DESCRIPTION:
# Get the name(s) of the device tree binary file(s) to include.

get_dtb_name() {
	local dtb_dir=${1}
	find ${dtb_dir} -name "*.dtb"
}

cros-kernel2_src_compile() {
	local build_targets=()  # use make default target
	local kernel_arch=${CHROMEOS_KERNEL_ARCH:-$(tc-arch-kernel)}
	case ${kernel_arch} in
		arm)
			build_targets=(
				$(usex device_tree 'zImage dtbs' uImage)
				$(usex boot_dts_device_tree dtbs '')
				$(cros_chkconfig_present MODULES && echo "modules")
			)
			;;
		mips)
			build_targets=(
				vmlinuz.bin
				$(usex device_tree 'dtbs' '')
				$(cros_chkconfig_present MODULES && echo "modules")
			)
			;;
	esac

	local src_dir="$(cros-workon_get_build_dir)/source"
	SMATCH_ERROR_FILE="${src_dir}/chromeos/check/smatch_errors.log"

	# If a .dts file is deleted from the source code it won't disappear
	# from the output in the next incremental build.  Nuke all dtbs so we
	# don't include stale files.  We use 'find' to handle old and new
	# locations (see comments in install below).
	find "$(cros-workon_get_build_dir)/arch" -name '*.dtb' -delete

	if use test && [[ -e "${SMATCH_ERROR_FILE}" ]]; then
		local make_check_cmd="smatch -p=kernel"
		local test_options=(
			CHECK="${make_check_cmd}"
			C=1
		)
		SMATCH_LOG_FILE="$(cros-workon_get_build_dir)/make.log"

		# The path names in the log file are build-dependent.  Strip out
		# the part of the path before "kernel/files" and retains what
		# comes after it: the file, line number, and error message.
		kmake -k ${build_targets[@]} "${test_options[@]}" |& \
			tee "${SMATCH_LOG_FILE}"
	else
		kmake -k ${build_targets[@]}
	fi
}

cros-kernel2_src_test() {
	[[ -e ${SMATCH_ERROR_FILE} ]] || \
		die "smatch whitelist file ${SMATCH_ERROR_FILE} not found!"
	[[ -e ${SMATCH_LOG_FILE} ]] || \
		die "Log file from src_compile() ${SMATCH_LOG_FILE} not found!"

	local prefix="$(realpath "${S}")/"
	grep -w error: "${SMATCH_LOG_FILE}" | grep -o "${prefix}.*" \
		| sed s:"${prefix}"::g > "${SMATCH_LOG_FILE}.errors"
	local num_errors=$(wc -l < "${SMATCH_LOG_FILE}.errors")
	local num_warnings=$(egrep -wc "warn:|warning:" "${SMATCH_LOG_FILE}")
	einfo "smatch found ${num_errors} errors and ${num_warnings} warnings."

	# Create a version of the error database that doesn't have line numbers,
	# since line numbers will shift as code is added or removed.
	local build_dir="$(cros-workon_get_build_dir)"
	local no_line_numbers_file="${build_dir}/no_line_numbers.log"
	sed -r -e "s/(:[0-9]+){1,2}//" \
	       -e "s/\(see line [0-9]+\)//" \
	       "${SMATCH_ERROR_FILE}" > "${no_line_numbers_file}"

	# For every smatch error that came up during the build, check if it is
	# in the error database file.
	local num_unknown_errors=0
	local line=""
	while read line; do
		local no_line_num=$(echo "${line}" | \
			sed -r -e "s/(:[0-9]+){1,2}//" \
			       -e "s/\(see line [0-9]+\)//")
		if ! fgrep -q "${no_line_num}" "${no_line_numbers_file}"; then
			eerror "Non-whitelisted error found: \"${line}\""
			: $(( ++num_unknown_errors ))
		fi
	done < "${SMATCH_LOG_FILE}.errors"

	[[ ${num_unknown_errors} -eq 0 ]] || \
		die "smatch found ${num_unknown_errors} unknown errors."
}

cros-kernel2_src_install() {
	local build_targets=(
		install
		$(usev firmware_install)
		$(cros_chkconfig_present MODULES && echo "modules_install")
	)

	dodir /boot
	kmake INSTALL_PATH="${D}/boot" INSTALL_MOD_PATH="${D}" \
		"${build_targets[@]}"

	local version=$(kernelrelease)
	local kernel_arch=${CHROMEOS_KERNEL_ARCH:-$(tc-arch-kernel)}
	local kernel_bin="${D}/boot/vmlinuz-${version}"
	if use arm || use mips; then
		local kernel_dir="$(cros-workon_get_build_dir)"
		local boot_dir="${kernel_dir}/arch/${kernel_arch}/boot"
		local zimage_bin="${D}/boot/zImage-${version}"
		local image_bin="${D}/boot/Image-${version}"
		local dtb_dir="${boot_dir}"

		# Newer kernels (after linux-next 12/3/12) put dtbs in the dts
		# dir.  Use that if we we find no dtbs directly in boot_dir.
		# Note that we try boot_dir first since the newer kernel will
		# actually rm ${boot_dir}/*.dtb so we'll have no stale files.
		if ! ls "${dtb_dir}"/*.dtb &> /dev/null; then
			dtb_dir="${boot_dir}/dts"
		fi

		if use device_tree; then
			local its_script="${kernel_dir}/its_script"
			emit_its_script "${its_script}" "${kernel_dir}" \
				$(get_dtb_name "${dtb_dir}")
			mkimage -D "-I dts -O dtb -p 2048" -f "${its_script}" "${kernel_bin}" || die
		elif [[ "${kernel_arch}" == "arm" ]]; then
			cp "${boot_dir}/uImage" "${kernel_bin}" || die
			if use boot_dts_device_tree; then
				# For boards where the device tree .dtb file is stored
				# under /boot/dts, loaded into memory, and then
				# passed on the 'bootm' command line, make sure they're
				# all installed.
				#
				# We install more .dtb files than we need, but it's
				# less work than a hard-coded list that gets out of
				# date.
				#
				# TODO(jrbarnette):  Really, this should use a
				# FIT image, same as other boards.
				insinto /boot/dts
				doins "${dtb_dir}"/*.dtb
			fi
		fi
		case ${kernel_arch} in
			arm)
				cp -a "${boot_dir}/zImage" "${zimage_bin}" || die
				;;
			arm64)
				cp -a "${boot_dir}/Image" "${image_bin}" || die
				;;
		esac
	fi
	if use arm || use mips; then
		# TODO(vbendeb): remove the below .uimg link creation code
		# after the build scripts have been modified to use the base
		# image name.
		cd $(dirname "${kernel_bin}")
		ln -sf $(basename "${kernel_bin}") vmlinux.uimg || die
		if use arm; then
			ln -sf $(basename "${zimage_bin}") zImage || die
		fi
	fi
	if [ ! -e "${D}/boot/vmlinuz" ]; then
		ln -sf "vmlinuz-${version}" "${D}/boot/vmlinuz" || die
	fi

	# Check the size of kernel image and issue warning when image size is near
	# the limit. For netboot initramfs, we don't care about kernel
	# size limit as the image is downloaded over network.
	local kernel_image_size=$(stat -c '%s' -L "${D}"/boot/vmlinuz)
	einfo "Kernel image size is ${kernel_image_size} bytes."
	if use factory_netboot_ramfs; then
		# No need to check kernel image size.
		true
	else
		if version_is_at_least 3.18 ; then
			kern_max=32
			kern_warn=12
		elif version_is_at_least 3.10 ; then
			kern_max=16
			kern_warn=12
		else
			kern_max=8
			kern_warn=7
		fi

		if [[ ${kernel_image_size} -gt $((kern_max * 1024 * 1024)) ]]; then
			die "Kernel image is larger than ${kern_max} MB."
		elif [[ ${kernel_image_size} -gt $((kern_warn * 1024 * 1024)) ]]; then
			ewarn "Kernel image is larger than ${kern_warn} MB. Limit is ${kern_max} MB."
		fi
	fi

	# Install uncompressed kernel for debugging purposes.
	insinto /usr/lib/debug/boot
	doins "$(cros-workon_get_build_dir)/vmlinux"

	# Also install the vdso shared ELFs for crash reporting.
	# We use slightly funky filenames so as to better integrate with
	# debugging processes (crash reporter/gdb/etc...).  The basename
	# will be the SONAME (what the runtime process sees), but since
	# that is not unique among all inputs, we also install into a dir
	# with the original filename.  e.g. we will install:
	#  /lib/modules/3.8.11/vdso/vdso32-syscall.so/linux-gate.so
	if use x86 || use amd64; then
		local vdso_dir d f soname
		vdso_dir="$(cros-workon_get_build_dir)/arch/x86/vdso"
		if [[ ! -d ${vdso_dir} ]]; then
			# Use new path with newer (>= v4.2-rc1) kernels
			vdso_dir="$(cros-workon_get_build_dir)/arch/x86/entry/vdso"
		fi
		[[ -d ${vdso_dir} ]] || die "could not find x86 vDSO dir"

		# Use the debug versions (.so.dbg) so portage can run splitdebug on them.
		for f in "${vdso_dir}"/vdso*.so.dbg; do
			d="/lib/modules/${version}/vdso/${f##*/}"

			exeinto "${d}"
			newexe "${f}" "linux-gate.so"

			soname=$(scanelf -qF'%S#f' "${f}")
			dosym "linux-gate.so" "${d}/${soname}"
		done
	fi

	if use kernel_sources; then
		install_kernel_sources
	else
		dosym "$(cros-workon_get_build_dir)" "/usr/src/linux"
	fi
}

EXPORT_FUNCTIONS pkg_setup src_prepare src_configure src_compile src_test src_install

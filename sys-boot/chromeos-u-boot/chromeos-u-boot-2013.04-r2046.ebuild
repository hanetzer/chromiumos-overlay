# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT=("cc72f5c47c758892b0f41257b0dd441a506ffdcd" "eedd4293582b86a43eab6400d0a967bccf14f1fe")
CROS_WORKON_TREE=("5e4cb7b3bbfda6cb32060b7d38b362f0b7706efb" "a9e83e621e99755a6efe0cbd60999f42c61261a3")
CROS_WORKON_PROJECT=("chromiumos/third_party/u-boot" "chromiumos/platform/vboot_reference")
CROS_WORKON_LOCALNAME=("u-boot" "../platform/vboot_reference")
CROS_WORKON_SUBDIR=("files" "")
VBOOT_REFERENCE_DESTDIR="${S}/vboot_reference"
CROS_WORKON_DESTDIR=("${S}" "${VBOOT_REFERENCE_DESTDIR}")

inherit toolchain-funcs flag-o-matic cros-workon

DESCRIPTION="Das U-Boot boot loader"
HOMEPAGE="http://www.denx.de/wiki/U-Boot"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="dalmore dev efs u_boot_netboot profiling smdk5420-u-boot"

DEPEND="!sys-boot/x86-firmware-fdts
	!sys-boot/exynos-u-boot
	!sys-boot/tegra2-public-firmware-fdts
	"

RDEPEND="${DEPEND}
	"

UB_BUILD_DIR="${WORKDIR}/build"
UB_BUILD_DIR_NB="${UB_BUILD_DIR%/}_nb"
UB_BUILD_DIR_RO="${UB_BUILD_DIR%/}_ro"

U_BOOT_CONFIG_USE_PREFIX="u_boot_config_use_"
ALL_CONFIGS=(
	beaglebone
	coreboot
	daisy
	peach
	seaboard
	venice
	venice2
	waluigi
)
IUSE_CONFIGS=${ALL_CONFIGS[@]/#/${U_BOOT_CONFIG_USE_PREFIX}}

IUSE="${IUSE} ${IUSE_CONFIGS}"

REQUIRED_USE="${REQUIRED_USE} ^^ ( ${IUSE_CONFIGS} )"

# @FUNCTION: get_current_u_boot_config
# @DESCRIPTION:
# Finds the config for the current board by searching USE for an entry
# signifying which version to use.
get_current_u_boot_config() {
	local use_config
	if use smdk5420-u-boot; then
		echo 'smdk5420_config'
		return
	fi
	# Dalmore support is implemented as a subprofile within the puppy
	# overlay (which supports venice by default).  To distinguish
	# between venice and dalmore, we see if the "dalmore" USE flag
	# is present.
	# We can't simply use U_BOOT_CONFIG_USE for dalmore because portage
	# appears to accumulate U_BOOT_CONFIG_USE with the base (venice)
	# and dalmore profiles, resulting in both venice and dalmore being
	# set in U_BOOT_CONFIG_USE and violating the exclusitivity described
	# in REQUIRED_USE of this ebuild.  Therefore, we have a special
	# case for dalmore using the "dalmore" USE flag.
	# When we don't care about dalmore anymore, we can refactor this
	# special case out.
	if use dalmore; then
		echo 'chromeos_dalmore_config'
		return
	fi
	for use_config in ${IUSE_CONFIGS}; do
		if use ${use_config}; then
			echo "chromeos_${use_config#${U_BOOT_CONFIG_USE_PREFIX}}_config"
			return
		fi
	done
	die "Unable to determine current U-Boot config."
}

# @FUNCTION: get_config_var
# @USAGE: <config name> <requested variable>
# @DESCRIPTION:
# Returns the value of the requested variable in the specified config
# if present. This can only be called after make config.
get_config_var() {
	local config="${1%_config}"
	local var="${2}"
	local boards_cfg="${S}/boards.cfg"
	local i
	case "${var}" in
	ARCH)	i=2;;
	CPU)	i=3;;
	BOARD)	i=4;;
	VENDOR)	i=5;;
	SOC)	i=6;;
	*)	die "Unsupported field: ${var}"
	esac
	awk -v i=$i -v cfg="${config}" '$1 == cfg { print $i }' "${boards_cfg}"
}

umake() {
	# Add `ARCH=` to reset ARCH env and let U-Boot choose it.
	ARCH= emake "${COMMON_MAKE_FLAGS[@]}" "$@"
}

src_configure() {
	export LDFLAGS=$(raw-ldflags)
	tc-export BUILD_CC

	CROS_U_BOOT_CONFIG="$(get_current_u_boot_config)"
	elog "Using U-Boot config: ${CROS_U_BOOT_CONFIG}"

	# Firmware related binaries are compiled with 32-bit toolchain
	# on 64-bit platforms
	if [[ ${CHOST} == x86_64-* ]]; then
		CROSS_PREFIX="i686-pc-linux-gnu-"
	else
		CROSS_PREFIX="${CHOST}-"
	fi

	COMMON_MAKE_FLAGS=(
		"CROSS_COMPILE=${CROSS_PREFIX}"
		"VBOOT_SOURCE=${VBOOT_REFERENCE_DESTDIR}"
		DEV_TREE_SEPARATE=1
		"HOSTCC=${BUILD_CC}"
		HOSTSTRIP=true
		USE_STDINT=1
		VBOOT_DEBUG=1
		QEMU_ARCH=
		WERROR=y
	)
	if use dev; then
		# Avoid hiding the errors and warnings
		COMMON_MAKE_FLAGS+=(
			-s
			QUIET=1
		)
	else
		COMMON_MAKE_FLAGS+=(
			-k
		)
	fi

	if use profiling; then
		COMMON_MAKE_FLAGS+=( VBOOT_PERFORMANCE=1 )
	fi

	BUILD_FLAGS=(
		"O=${UB_BUILD_DIR}"
	)

	umake "${BUILD_FLAGS[@]}" distclean
	umake "${BUILD_FLAGS[@]}" ${CROS_U_BOOT_CONFIG}

	if use u_boot_netboot; then
		BUILD_NB_FLAGS=(
			"O=${UB_BUILD_DIR_NB}"
			BUILD_FACTORY_IMAGE=1
		)
		umake "${BUILD_NB_FLAGS[@]}" distclean
		umake "${BUILD_NB_FLAGS[@]}" ${CROS_U_BOOT_CONFIG}
	fi

	if use efs; then
		BUILD_RO_FLAGS=(
			"O=${UB_BUILD_DIR_RO}"
			CROS_RO=1
			CROS_SMALL=1
		)
		umake "${BUILD_RO_FLAGS[@]}" distclean
		umake "${BUILD_RO_FLAGS[@]}" ${CROS_U_BOOT_CONFIG}
	fi
}

src_compile() {
	umake "${BUILD_FLAGS[@]}" all

	if use u_boot_netboot; then
		umake "${BUILD_NB_FLAGS[@]}" all
	fi
	if use efs; then
		umake "${BUILD_RO_FLAGS[@]}" all
	fi
}

src_install() {
	local inst_dir="/firmware"
	local files_to_copy=(
		System.map
		u-boot
		u-boot.bin
		u-boot.img
		$(usex u_boot_config_use_beaglebone MLO)
	)
	local f

	insinto "${inst_dir}"

	# Daisy, peach and their variants need an SPL binary.
	if use u_boot_config_use_daisy || use u_boot_config_use_peach ; then
		local ub_board="$(get_config_var ${CROS_U_BOOT_CONFIG} BOARD)"
		local spl_bin="spl/${ub_board}-spl.bin"
		local spl_map="spl/System.spl.map"

		newins "${UB_BUILD_DIR}/${spl_bin}" u-boot-spl.wrapped.bin
		newins "${UB_BUILD_DIR}/${spl_map}" System.spl.map
		if use efs; then
			newins "${UB_BUILD_DIR_RO}/u-boot.bin" u-boot-ro.bin
			# The read-only SPL to be used, once we start building
			# it using its own conffiguration
			newins "${UB_BUILD_DIR_RO}/${spl_bin}" \
				u-boot-spl-ro.wrapped.bin
			newins "${UB_BUILD_DIR_RO}/${spl_map}" \
				System.spl-ro.map
		fi
	fi

	for f in "${files_to_copy[@]}"; do
		[[ -f "${UB_BUILD_DIR}/${f}" ]] &&
			doins "${f/#/${UB_BUILD_DIR}/}"
	done

	# u-boot-nodtb-tegra.bin has prepended SPL but no appended DTB.
	if use u_boot_config_use_venice || use u_boot_config_use_venice2; then
		newins "${UB_BUILD_DIR}/u-boot-nodtb-tegra.bin" u-boot.bin
	fi

	if use u_boot_netboot; then
		newins "${UB_BUILD_DIR_NB}/u-boot.bin" u-boot_netboot.bin
	fi

	if ! use u_boot_config_use_beaglebone; then
		insinto "${inst_dir}/dtb"
		doins "${UB_BUILD_DIR}/dts/"*.dtb
	fi
}

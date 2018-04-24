# Copyright (c) 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# Change this version number when any change is made to configs/files under
# coreboot and an auto-revbump is required.
# VERSION=REVBUMP-0.0.16

EAPI=5
CROS_WORKON_COMMIT=("cd626fc5fd2c13f3a0292eda20eaef0f532af389" "10787b0519afce1e887a935789b2d624849856a9" "392211f0358919d510179ad399d8f056180e652e" "8e9f99b3e60d0ffe8b67cc93ea4ab1b9ed191e45" "b7d5b2d6a6dd05874d86ee900ff441d261f9034c")
CROS_WORKON_TREE=("d112d3612ae1f5915e7e338b97b1a1e3ca6b33fa" "5ed29dfb7d8a4bab0d7c89bcd16811734eca346c" "3326672902a056c1b70520574aa14724a550dfdd" "4bcd8687cf9a0783cdd166da727b5a886dbddc73" "c0433b88f972fa26dded401be022c1c026cd644e")
CROS_WORKON_PROJECT=(
	"chromiumos/third_party/coreboot"
	"chromiumos/third_party/arm-trusted-firmware"
	"chromiumos/platform/vboot_reference"
	"chromiumos/third_party/coreboot/blobs"
	"chromiumos/third_party/cbootimage"
)
CROS_WORKON_LOCALNAME=(
	"coreboot"
	"arm-trusted-firmware"
	"../platform/vboot_reference"
	"coreboot/3rdparty/blobs"
	"cbootimage"
)
CROS_WORKON_DESTDIR=(
	"${S}"
	"${S}/3rdparty/arm-trusted-firmware"
	"${S}/3rdparty/vboot"
	"${S}/3rdparty/blobs"
	"${S}/util/nvidia/cbootimage"
)

inherit cros-board cros-workon toolchain-funcs cros-unibuild coreboot-sdk

DESCRIPTION="coreboot firmware"
HOMEPAGE="http://www.coreboot.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="em100-mode fastboot fsp memmaps mocktpm quiet-cb rmt vmx mtc mma"
IUSE="${IUSE} +bmpblk cros_ec +intel_mrc pd_sync qca-framework quiet unibuild verbose"
IUSE="${IUSE} amd_cpu coreboot-sdk"
# coreboot's build system handles stripping the binaries and producing a
# separate .debug file with the symbols. This flag prevents portage from
# stripping the .debug symbols
RESTRICT="strip"

PER_BOARD_BOARDS=(
	atlas bayleybay beltino bolt butterfly chell cyan daisy eve falco
	fizz fox glados glkrvp grunt kahlee kunimitsu link lumpy nami
	nyan octopus panther parrot peppy poppy rambi samus sklrvp slippy
	stout stout32 strago stumpy urara variant-peach-pit
)

DEPEND_BLOCKERS="${PER_BOARD_BOARDS[@]/#/!sys-boot/chromeos-coreboot-}"

RDEPEND="
	${DEPEND_BLOCKERS}
	!virtual/chromeos-coreboot
	"

DEPEND="
	mtc? ( sys-boot/mtc )
	${DEPEND_BLOCKERS}
	virtual/coreboot-private-files
	bmpblk? ( sys-boot/chromeos-bmpblk )
	cros_ec? ( chromeos-base/chromeos-ec )
	pd_sync? ( chromeos-base/chromeos-ec )
	intel_mrc? ( x86? ( sys-boot/chromeos-mrc )
		amd64? ( sys-boot/chromeos-mrc ) )
	amd_cpu? ( sys-boot/amd-firmware )
	qca-framework? ( sys-boot/qca-framework )
	unibuild? ( chromeos-base/chromeos-config )
	"

# Get the coreboot board config to build for.
# Checks the current board with/without variant, and also whether an FSP
# is in use. Echoes the board config file that should be used to build
# coreboot.
get_board() {
	local board=$(get_current_board_with_variant)

	if [[ ! -s "${FILESDIR}/configs/config.${board}" ]]; then
		board=$(get_current_board_no_variant)
	fi
	echo "${board}"
}

set_build_env() {
	BOARD="$1"
	BUILD_TARGET_NAME="$2"

	if use unibuild; then
		CONFIG=".config-${BOARD}"
		CONFIG_SERIAL=".config_serial-${BOARD}"
		BUILD_DIR="build-${BUILD_TARGET_NAME}"
		BUILD_DIR_SERIAL="build_serial-${BUILD_TARGET_NAME}"
	else
		CONFIG=".config"
		CONFIG_SERIAL=".config_serial"
		BUILD_DIR="build"
		BUILD_DIR_SERIAL="build_serial"
	fi
}

# Create the coreboot configuration files for a particular board. This
# creates a standard config and a serial config.
# Args:
#   $1: Base board name, if any (used for unified builds)
create_config() {
	# TODO(teravest): Remove this arg and replace with family lookup.
	local base_board="$1"

	if [[ -s "${FILESDIR}/configs/config.${BOARD}" ]]; then

		cp -v "${FILESDIR}/configs/config.${BOARD}" "${CONFIG}"

		# Override mainboard vendor if needed.
		if [[ -n "${SYSTEM_OEM}" ]]; then
			echo "CONFIG_MAINBOARD_VENDOR=\"${SYSTEM_OEM}\"" >> "${CONFIG}"
		fi

		# In case config comes from a symlink we are likely building
		# for an overlay not matching this config name. Enable adding
		# a CBFS based board ID for coreboot.
		if [[ -L "${FILESDIR}/configs/config.${BOARD}" ]]; then
			echo "CONFIG_BOARD_ID_MANUAL=y" >> "${CONFIG}"
			echo "CONFIG_BOARD_ID_STRING=\"${BOARD_USE}\"" >> "${CONFIG}"
		fi
	fi

	if use rmt; then
		echo "CONFIG_MRC_RMT=y" >> "${CONFIG}"
	fi
	if use vmx; then
		elog "   - enabling VMX"
		echo "CONFIG_ENABLE_VMX=y" >> "${CONFIG}"
	fi
	if use quiet-cb; then
		# Suppress console spew if requested.
		cat >> "${CONFIG}" <<EOF
CONFIG_DEFAULT_CONSOLE_LOGLEVEL=3
# CONFIG_DEFAULT_CONSOLE_LOGLEVEL_8 is not set
CONFIG_DEFAULT_CONSOLE_LOGLEVEL_3=y
EOF
	fi
	if use mocktpm; then
		echo "CONFIG_VBOOT_MOCK_SECDATA=y" >> "${CONFIG}"
	fi
	if use mma; then
		echo "CONFIG_MMA=y" >> "${CONFIG}"
	fi

	# allow using non-coreboot toolchains unless we use it anyway
	if ! use coreboot-sdk; then
		echo "CONFIG_ANY_TOOLCHAIN=y" >> "${CONFIG}"
	fi
	# disable coreboot's own EC firmware building mechanism
	echo "CONFIG_EC_GOOGLE_CHROMEEC_FIRMWARE_NONE=y" >> "${CONFIG}"
	echo "CONFIG_EC_GOOGLE_CHROMEEC_PD_FIRMWARE_NONE=y" >> "${CONFIG}"
	# enable common GBB flags for development
	echo "CONFIG_GBB_FLAG_DEV_SCREEN_SHORT_DELAY=y" >> "${CONFIG}"
	echo "CONFIG_GBB_FLAG_DISABLE_FW_ROLLBACK_CHECK=y" >> "${CONFIG}"
	echo "CONFIG_GBB_FLAG_FORCE_DEV_BOOT_USB=y" >> "${CONFIG}"
	echo "CONFIG_GBB_FLAG_FORCE_DEV_SWITCH_ON=y" >> "${CONFIG}"
	if use fastboot; then
		echo "CONFIG_GBB_FLAG_FORCE_DEV_BOOT_FASTBOOT_FULL_CAP=y" >> "${CONFIG}"
	fi
	local version=$(${CHROOT_SOURCE_ROOT}/src/third_party/chromiumos-overlay/chromeos/config/chromeos_version.sh |grep "^[[:space:]]*CHROMEOS_VERSION_STRING=" |cut -d= -f2)
	echo "CONFIG_VBOOT_FWID_VERSION=\".${version}\"" >> "${CONFIG}"

	cp "${CONFIG}" "${CONFIG_SERIAL}"
	# handle the case when "${CONFIG}" does not have a newline in the end.
	echo >> "${CONFIG_SERIAL}"
	file="${FILESDIR}/configs/fwserial.${BOARD}"
	if [ ! -f "${file}" ] && [ -n "${base_board}" ]; then
		file="${FILESDIR}/configs/fwserial.${base_board}"
	fi
	if [ ! -f "${file}" ]; then
		file="${FILESDIR}/configs/fwserial.default"
	fi
	cat "${file}" >> "${CONFIG_SERIAL}" || die

	einfo "Configured ${CONFIG} for board ${BOARD} in ${BUILD_DIR}"
}

src_prepare() {
	local froot="${SYSROOT}/firmware"
	local privdir="${SYSROOT}/firmware/coreboot-private"
	local file

	if [[ -d "${privdir}" ]]; then
		while read -d $'\0' -r file; do
			rsync --recursive --links --executability \
				"${file}" ./ || die
		done < <(find "${privdir}" -maxdepth 1 -mindepth 1 -print0)
	fi

	for blob in mrc.bin mrc.elf efi.elf; do
		if [[ -r "${SYSROOT}/firmware/${blob}" ]]; then
			cp "${SYSROOT}/firmware/${blob}" 3rdparty/blobs/
		fi
	done

	if use unibuild; then
		local build_target

		local fields="coreboot,ec"
		local cmd="get-firmware-build-combinations"
		(cros_config_host "${cmd}" "${fields}" || die) |
		while read -r name; do
			read -r coreboot
			read -r ec
			set_build_env "${coreboot}" "${name}"
			create_config "$(get_board)"
		done
	else
		set_build_env "$(get_board)"
		create_config
	fi
}

# Returns true if EC supports EFS.
is_ec_efs_enabled() {
	grep -q "^CONFIG_VBOOT_EC_EFS=y$" "${CONFIG}"
}

add_ec() {
	local rom="$1"
	local name="$2"
	local ecroot="$3"
	local pad="0"

	is_ec_efs_enabled && pad="128"
	einfo "Padding ecrw ${pad} byte."
	cbfstool "${rom}" add -r FW_MAIN_A,FW_MAIN_B -t raw -c lzma \
		-f "${ecroot}/ec.RW.bin" -n "${name}" -p "${pad}" || die
	cbfstool "${rom}" add -r FW_MAIN_A,FW_MAIN_B -t raw -c none \
		-f "${ecroot}/ec.RW.hash" -n "${name}.hash" || die
}

add_fw_blob() {
	local rom="$1"
	local cbname="$2"
	local blob="$3"
	local cbhash="${cbname%.bin}.hash"
	local hash="${blob%.bin}.hash"

	cbfstool "${rom}" add -r FW_MAIN_A,FW_MAIN_B -t raw -c lzma \
		-f "${blob}" -n "${cbname}" || die
	cbfstool "${rom}" add -r FW_MAIN_A,FW_MAIN_B -t raw -c none \
		-f "${hash}" -n "${cbhash}" || die
}

# Build coreboot with a supplied configuration and output directory.
#   $1: Build directory to use (e.g. "build_serial")
#   $2: Config file to use (e.g. ".config_serial")
#   $3: Build target build (e.g. "pyro"), for USE=unibuild only.
#   $4: Build target ec (e.g. "pyro"), for USE=unibuild only.
make_coreboot() {
	local builddir="$1"
	local config_fname="$2"
	local build_target="$3"
	local ec_target="$4"
	local froot="${SYSROOT}/firmware"
	local fblobroot="${SYSROOT}/firmware"

	if use unibuild; then
		froot+="/${build_target}"
	fi
	rm -rf "${builddir}" .xcompile

	local CB_OPTS=( "objutil=objutil" "DOTCONFIG=${config_fname}" )
	use quiet && CB_OPTS+=( "V=0" )
	use verbose && CB_OPTS+=( "V=1" )
	use quiet && REDIR="/dev/null" || REDIR="/dev/stdout"

	# Configure and build coreboot.
	yes "" | emake oldconfig "${CB_OPTS[@]}" obj="${builddir}" >${REDIR}
	emake "${CB_OPTS[@]}" obj="${builddir}"

	# Expand FW_MAIN_* since we might add some files
	cbfstool "${builddir}/coreboot.rom" expand -r FW_MAIN_A,FW_MAIN_B

	# Record the config that we used.
	cp "${config_fname}" "${builddir}/${config_fname}"

	# Modify firmware descriptor if building for the EM100 emulator.
	if use em100-mode; then
		ifdtool --em100 "${builddir}/coreboot.rom" || die
		mv "${builddir}/coreboot.rom"{.new,} || die
	fi

	if use cros_ec; then
		if use unibuild; then
			einfo "Adding ec for ${ec_target}"
			add_ec "${builddir}/coreboot.rom" "ecrw" \
				"${SYSROOT}/firmware/${ec_target}"
		else
			add_ec "${builddir}/coreboot.rom" "ecrw" "${froot}"
		fi
	fi

	if use pd_sync; then
		add_ec "${builddir}/coreboot.rom" "pdrw" \
			"${froot}/${PD_FIRMWARE}" ||
			die "Could not add PD in '${froot}/${PD_FIRMWARE}' \
to Coreboot"
	fi

	local blob
	local cbname
	for blob in ${FW_BLOBS}; do
		cbname=$(basename "${blob}")
		add_fw_blob "${builddir}/coreboot.rom" "${cbname}" \
			"${fblobroot}/${blob}" || die
	done

	( cd "${froot}/cbfs" 2>/dev/null && find . -type f) | \
	while read file; do
		file="${file:2}" # strip ./ prefix
		cbfstool "${builddir}/coreboot.rom" add \
			-r COREBOOT,FW_MAIN_A,FW_MAIN_B \
			-f "${froot}/cbfs/$file" \
			-n "$file" \
			-t raw -c lzma
	done
}

src_compile() {
	# Set KERNELREVISION (really coreboot revision) to the ebuild revision
	# number followed by a dot and the first seven characters of the git
	# hash. The name is confusing but consistent with the coreboot
	# Makefile.
	local sha1v="${VCSID/*-/}"
	export KERNELREVISION=".${PV}.${sha1v:0:7}"

	if ! use coreboot-sdk; then
		tc-export CC
		# Export the known cross compilers so there isn't a reliance
		# on what the default profile is for exporting a compiler. The
		# reasoning is that the firmware may need more than one to build
		# and boot.
		export CROSS_COMPILE_x86="i686-pc-linux-gnu-"
		export CROSS_COMPILE_mipsel="mipsel-cros-linux-gnu-"
		export CROSS_COMPILE_arm64="aarch64-cros-linux-gnu-"
		export CROSS_COMPILE_arm="armv7a-cros-linux-gnu- armv7a-cros-linux-gnueabi-"
	else
		export CROSS_COMPILE_x86=${COREBOOT_SDK_PREFIX_x86_32}
		export CROSS_COMPILE_mipsel=${COREBOOT_SDK_PREFIX_mips}
		export CROSS_COMPILE_arm64=${COREBOOT_SDK_PREFIX_arm64}
		export CROSS_COMPILE_arm=${COREBOOT_SDK_PREFIX_arm}

		export PATH=/opt/coreboot-sdk/bin:$PATH
	fi

	use verbose && elog "Toolchain:\n$(sh util/xcompile/xcompile)\n"

	if use unibuild; then
		local fields="coreboot,ec"
		local cmd="get-firmware-build-combinations"
		(cros_config_host "${cmd}" "${fields}" || die) |
		while read -r name; do
			read -r coreboot
			read -r ec

			set_build_env "${coreboot}" "${name}"
			make_coreboot "${BUILD_DIR}" "${CONFIG}" "${name}" \
				"${ec}"

			# Build a second ROM with serial support for developers.
			make_coreboot "${BUILD_DIR_SERIAL}" "${CONFIG_SERIAL}" \
				"${name}" "${ec}"
		done
	else
		set_build_env "$(get_board)"
		make_coreboot "${BUILD_DIR}" "${CONFIG}"

		# Build a second ROM with serial support for developers.
		make_coreboot "${BUILD_DIR_SERIAL}" "${CONFIG_SERIAL}"
	fi
}

do_install() {
	local build_target="$1"
	local dest_dir="/firmware"
	local mapfile

	if [[ -n "${build_target}" ]]; then
		dest_dir+="/${build_target}"
		einfo "Installing coreboot ${build_target} into ${dest_dir}"
	fi
	insinto "${dest_dir}"

	newins "${BUILD_DIR}/coreboot.rom" coreboot.rom
	newins "${BUILD_DIR_SERIAL}/coreboot.rom" coreboot.rom.serial

	local config_file="${FILESDIR}/configs/config.$(get_board)"
	OPROM=$( awk 'BEGIN{FS="\""} /CONFIG_VGA_BIOS_FILE=/ { print $2 }' \
		"${config_file}" )
	CBFSOPROM=pci$( awk 'BEGIN{FS="\""} /CONFIG_VGA_BIOS_ID=/ { print $2 }' \
		"${config_file}" ).rom
	FSP=$( awk 'BEGIN{FS="\""} /CONFIG_FSP_FILE=/ { print $2 }' \
		"${config_file}" )
	if [[ -n "${FSP}" ]]; then
		newins ${FSP} fsp.bin
	fi
	if [[ -n "${OPROM}" ]]; then
		newins ${OPROM} ${CBFSOPROM}
	fi
	if use memmaps; then
		for mapfile in "${BUILD_DIR}"/cbfs/fallback/*.map
		do
			doins $mapfile
		done
	fi
	newins "${BUILD_DIR}/${CONFIG}" coreboot.config
	newins "${BUILD_DIR_SERIAL}/${CONFIG_SERIAL}" coreboot_serial.config

	# Keep binaries with debug symbols around for crash dump analysis
	if [[ -s "${BUILD_DIR}/bl31.elf" ]]; then
		newins "${BUILD_DIR}/bl31.elf" bl31.elf
		newins "${BUILD_DIR_SERIAL}/bl31.elf" bl31.serial.elf
	fi
	insinto "${dest_dir}"/coreboot
	doins "${BUILD_DIR}"/cbfs/fallback/*.debug
	insinto "${dest_dir}"/coreboot_serial
	doins "${BUILD_DIR_SERIAL}"/cbfs/fallback/*.debug
}

src_install() {
	local build_target

	if use unibuild; then
		local fields="coreboot,ec"
		local cmd="get-firmware-build-combinations"
		(cros_config_host "${cmd}" "${fields}" || die) |
		while read -r name; do
			read -r coreboot
			read -r ec

			set_build_env "${coreboot}" "${name}"
			do_install ${coreboot}
		done
	else
		set_build_env
		do_install
	fi
}

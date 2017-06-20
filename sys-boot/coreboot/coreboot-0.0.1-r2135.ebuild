# Copyright (c) 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# Change this version number when any change is made to configs/files under
# coreboot and an auto-revbump is required.
# VERSION=REVBUMP-0.0.3

EAPI=4
CROS_WORKON_COMMIT=("4fcce9da0a1b62b46ed78c522f6fcbf51ff5974e" "4fd4af26cb650d34876c058a7142c91233ba5475" "4007d6ff218110d55830c6dc2ca9822825afa0da" "9ba07035ed0acb28902cce826ea833cf531d57c1" "b7d5b2d6a6dd05874d86ee900ff441d261f9034c")
CROS_WORKON_TREE=("17f26cee20f69b283b8e76547bea16318912c677" "63a780f9aa4042ef4da78bcd1442b8f541612074" "27c289a36cec0131a909175c8512f704dfe9e273" "f78a5cfb57197350a309e2d2a93b09fe308f9c5f" "c0433b88f972fa26dded401be022c1c026cd644e")
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

inherit cros-board cros-workon toolchain-funcs

DESCRIPTION="coreboot firmware"
HOMEPAGE="http://www.coreboot.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="em100-mode fastboot fsp memmaps mocktpm quiet-cb rmt vmx mtc mma"
IUSE="${IUSE} +bmpblk cros_ec pd_sync qca-framework quiet unibuild verbose"

PER_BOARD_BOARDS=(
	bayleybay beltino bolt butterfly chell cyan daisy eve falco fizz fox glados
	kunimitsu link lumpy nyan panther parrot peppy poppy rambi samus sklrvp
	slippy stout stout32 strago stumpy urara variant-peach-pit
)

DEPEND_BLOCKERS="${PER_BOARD_BOARDS[@]/#/!sys-boot/chromeos-coreboot-}"

RDEPEND="
	${DEPEND_BLOCKERS}
	!virtual/chromeos-coreboot
	"

# Dependency shared by x86 and amd64.
DEPEND_X86="
	sys-power/iasl
	sys-boot/chromeos-mrc
	"
DEPEND="
	mtc? ( sys-boot/mtc )
	chromeos-base/vboot_reference
	${DEPEND_BLOCKERS}
	virtual/coreboot-private-files
	sys-apps/coreboot-utils
	bmpblk? ( sys-boot/chromeos-bmpblk )
	cros_ec? ( chromeos-base/chromeos-ec )
	pd_sync? ( chromeos-base/chromeos-ec )
	x86? ($DEPEND_X86)
	amd64? ($DEPEND_X86)
	qca-framework? ( sys-boot/qca-framework )
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
	if use fsp; then
		if [[ -s "${FILESDIR}/configs/config.${board}.fsp" ]]; then
			elog "   - using fsp config"
			board=${board}.fsp
		fi
	fi
	echo "${board}"
}

set_build_env() {
	BOARD="$1"

	if use unibuild; then
		CONFIG=".config-${BOARD}"
		CONFIG_SERIAL=".config_serial-${BOARD}"
		BUILD_DIR="build-${model}"
		BUILD_DIR_SERIAL="build_serial-${model}"
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
#   $1: Name of board to create a configure file for (e.g. "reef")
#   $2: Base board name, if any (used for unified builds)
create_config() {
	local base_board="$2"

	set_build_env "$1"

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
	echo "CONFIG_GBB_FLAG_ENABLE_SERIAL=y" >> "${CONFIG_SERIAL}"

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
		local model

		for model in ${FIRMWARE_UNIBUILD}; do
			create_config "${model}" "$(get_board)"
		done
	else
		create_config "$(get_board)"
	fi
}

add_ec() {
	local rom="$1"
	local name="$2"
	local ecroot="$3"

	cbfstool "${rom}" add -r FW_MAIN_A,FW_MAIN_B -t raw -c lzma \
		-f "${ecroot}/ec.RW.bin" -n "${name}" || die
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
#   $3: Model name to build (e.g. "pyro"), for USE=unibuild only.
make_coreboot() {
	local builddir="$1"
	local config_fname="$2"
	local model="$3"
	local froot="${SYSROOT}/firmware"
	local fblobroot="${SYSROOT}/firmware"

	if use unibuild; then
		froot+="/${model}"
	fi
	rm -rf "${builddir}" .xcompile

	local CB_OPTS=( "objutil=objutil" "DOTCONFIG=${config_fname}" )
	use quiet && CB_OPTS+=( "V=0" )
	use verbose && CB_OPTS+=( "V=1" )
	use quiet && REDIR="/dev/null" || REDIR="/dev/stdout"

	# Configure and build coreboot.
	yes "" | emake oldconfig "${CB_OPTS[@]}" obj="${builddir}" >${REDIR}
	emake "${CB_OPTS[@]}" obj="${builddir}"

	# Record the config that we used.
	cp "${config_fname}" "${builddir}/${config_fname}"

	# Modify firmware descriptor if building for the EM100 emulator.
	if use em100-mode; then
		ifdtool --em100 "${builddir}/coreboot.rom" || die
		mv "${builddir}/coreboot.rom"{.new,} || die
	fi

	if use cros_ec; then
		add_ec "${builddir}/coreboot.rom" "ecrw" "${froot}"
	fi

	if use pd_sync; then
		add_ec "${builddir}/coreboot.rom" "pdrw" "${froot}/${PD_FIRMWARE}"
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
	tc-export CC

	# Set KERNELREVISION (really coreboot revision) to the ebuild revision
	# number followed by a dot and the first seven characters of the git
	# hash. The name is confusing but consistent with the coreboot
	# Makefile.
	local sha1v="${VCSID/*-/}"
	export KERNELREVISION=".${PV}.${sha1v:0:7}"

	# Export the known cross compilers so there isn't a reliance
	# on what the default profile is for exporting a compiler. The
	# reasoning is that the firmware may need more than one to build
	# and boot.
	export CROSS_COMPILE_i386="i686-pc-linux-gnu-"
	# For coreboot.org upstream architecture naming.
	export CROSS_COMPILE_x86="i686-pc-linux-gnu-"
	export CROSS_COMPILE_mipsel="mipsel-cros-linux-gnu-"
	# aarch64: used on chromeos-2013.04
	export CROSS_COMPILE_aarch64="aarch64-cros-linux-gnu-"
	# arm64: used on coreboot upstream
	export CROSS_COMPILE_arm64="aarch64-cros-linux-gnu-"
	export CROSS_COMPILE_arm="armv7a-cros-linux-gnu- armv7a-cros-linux-gnueabi-"

	use verbose && elog "Toolchain:\n$(sh util/xcompile/xcompile)\n"

	# Build a second ROM with serial support for developers.
	if use unibuild; then
		local model

		for model in ${FIRMWARE_UNIBUILD}; do
			set_build_env "${model}"
			make_coreboot "${BUILD_DIR}" "${CONFIG}" "${model}"
			make_coreboot "${BUILD_DIR_SERIAL}" "${CONFIG_SERIAL}" \
				"${model}"
		done
	else
		set_build_env "$(get_board)"
		make_coreboot "${BUILD_DIR}" "${CONFIG}"
		make_coreboot "${BUILD_DIR_SERIAL}" "${CONFIG_SERIAL}"
	fi
}

do_install() {
	local model="$1"
	local dest_dir="/firmware"
	local mapfile

	if [[ -n "${model}" ]]; then
		dest_dir+="/${model}"
		einfo "Installing coreboot ${model} into ${dest_dir}"
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
		newins "${BUILD_DIR}/bl31.elf" bl31.serial.elf
	fi
	insinto "${dest_dir}"/coreboot
	doins "${BUILD_DIR}"/cbfs/fallback/*.debug
	insinto "${dest_dir}"/coreboot_serial
	doins "${BUILD_DIR_SERIAL}"/cbfs/fallback/*.debug
}

src_install() {
	local model

	if use unibuild; then
		for model in ${FIRMWARE_UNIBUILD}; do
			set_build_env "${model}" "$(get_board)"
			do_install ${model}
		done
	else
		set_build_env "$(get_board)"
		do_install
	fi
}

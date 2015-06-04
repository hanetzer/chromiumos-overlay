# Copyright (c) 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT=("a37d84310db01524d98c14c40cc3f61c9fcc8106" "de975e85ff4a3712fc8ff8aa5556e0ec0a11e63c" "3479e84e3041336f1e967c302c5a35cb64819927" "5f33d05693f14d13a532b465ac01bfcc6134cb61")
CROS_WORKON_TREE=("435ee1c85f68d21d3f3ce32667ed3d16218e4845" "f1651a5dc15513e1a4c60e2ed9800ff8b31dec92" "0fb1c4ad8766579de88b8335680a84ecc6bf8a97" "9094872ac0fbbd14102aa98872b35d298bafdf91")
CROS_WORKON_PROJECT=(
	"chromiumos/third_party/coreboot"
	"chromiumos/third_party/arm-trusted-firmware"
	"chromiumos/platform/vboot_reference"
	"chromiumos/third_party/coreboot/blobs"
)
CROS_WORKON_LOCALNAME=(
	"coreboot"
	"arm-trusted-firmware"
	"../platform/vboot_reference"
	"coreboot/3rdparty"
)
CROS_WORKON_DESTDIR=(
	"${S}"
	"${S}/3rdparty/arm-trusted-firmware"
	"${S}/3rdparty/vboot"
	"${S}/3rdparty/blobs"
)

inherit cros-board cros-workon toolchain-funcs

DESCRIPTION="coreboot firmware"
HOMEPAGE="http://www.coreboot.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="em100-mode fsp memmaps mocktpm quiet-cb rmt vmx"

PER_BOARD_BOARDS=(
	bayleybay beltino bolt butterfly cyan daisy falco fox gizmo glados kunimitsu
	link lumpy nyan panther parrot peppy rambi samus sklrvp slippy stout stout32
	strago stumpy urara variant-peach-pit
)

DEPEND_BLOCKERS="${PER_BOARD_BOARDS[@]/#/!sys-boot/chromeos-coreboot-}"

RDEPEND="
	${DEPEND_BLOCKERS}
	!virtual/chromeos-coreboot
	"

# Dependency shared by x86 and amd64.
DEPEND_X86="
	sys-power/iasl
	!fsp? ( sys-boot/chromeos-mrc )
	"
DEPEND="
	chromeos-base/vboot_reference
	${DEPEND_BLOCKERS}
	virtual/coreboot-private-files
	sys-apps/coreboot-utils
	x86? ($DEPEND_X86)
	amd64? ($DEPEND_X86)
	"

VERIFIED_STAGES=( "ramstage" "romstage" "refcode" "bl31" "secure_os" )

src_prepare() {
	local privdir="${SYSROOT}/firmware/coreboot-private"
	local file

	if [[ -d "${privdir}" ]]; then
		while read -d $'\0' -r file; do
			rsync --recursive --links --executability --ignore-existing \
			      "${file}" ./ || die
		done < <(find "${privdir}" -maxdepth 1 -mindepth 1 -print0)
	fi

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

	if [[ -s "${FILESDIR}/configs/config.${board}" ]]; then

		emake clean  # in case someone tried a local make, ensure
			     # there is no leftovers

		cp -v "${FILESDIR}/configs/config.${board}" .config

		# In case config comes from a symlink we are likely building
		# for an overlay not matching this config name. Enable adding
		# a CBFS based board ID for coreboot.
		if [[ -L "${FILESDIR}/configs/config.${board}" ]]; then
			echo "CONFIG_BOARD_ID_MANUAL=y" >> .config
			echo "CONFIG_BOARD_ID_STRING=\"${BOARD_USE}\"" >> .config
		fi
	fi

	# Replace the hard coded /build/<board>/ in the config with the actual
	# sysroot.
	# TODO: crbug.com/388888 coreboot configs should not hardcode the
	# sysroot path.
	sed -i 's#/build/[^/]*#${SYSROOT}#' .config || die

	if use rmt; then
		echo "CONFIG_MRC_RMT=y" >> .config
	fi
	if use vmx; then
		elog "   - enabling VMX"
		echo "CONFIG_ENABLE_VMX=y" >> .config
	fi
	if use quiet-cb; then
		# Suppress console spew if requested.
		cat >> .config <<EOF
CONFIG_DEFAULT_CONSOLE_LOGLEVEL=3
# CONFIG_DEFAULT_CONSOLE_LOGLEVEL_8 is not set
CONFIG_DEFAULT_CONSOLE_LOGLEVEL_3=y
EOF
	fi
	if use mocktpm; then
		echo "CONFIG_VBOOT2_MOCK_SECDATA=y" >> .config
	fi

	cp .config .config_serial
	# handle the case when .config does not have a newline in the end.
	echo >> .config_serial
	cat "${FILESDIR}/configs/fwserial.${board}" >> .config_serial || die
}

make_coreboot() {
	local builddir="$1"

	yes "" | emake oldconfig
	emake obj="${builddir}"

	# Modify firmware descriptor if building for the EM100 emulator.
	if use em100-mode; then
		ifdtool --em100 "${builddir}/coreboot.rom" || die
		mv "${builddir}/coreboot.rom"{.new,} || die
	fi

	# Extract stages which may need to be repackaged for vboot, if present.
	for stage in ${VERIFIED_STAGES[@]}; do
		cbfstool "${builddir}/coreboot.rom" extract \
			-n "fallback/${stage}" \
			-f "${builddir}/${stage}.stage" || true
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
	export CROSS_COMPILE_mipsel="mipsel-cros-linux-gnu-"
	# aarch64: used on chromeos-2013.04
	export CROSS_COMPILE_aarch64="aarch64-cros-linux-gnu-"
	# arm64: used on coreboot upstream
	export CROSS_COMPILE_arm64="aarch64-cros-linux-gnu-"
	export CROSS_COMPILE_arm="armv7a-cros-linux-gnu- armv7a-cros-linux-gnueabi-"

	elog "Toolchain:\n$(sh util/xcompile/xcompile)\n"

	make_coreboot "build"

	# Build a second ROM with serial support for developers
	mv .config_serial .config
	make_coreboot "build_serial"
}

src_install() {
	local mapfile
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

	insinto /firmware

	newins "build/coreboot.rom" coreboot.rom
	newins "build_serial/coreboot.rom" coreboot.rom.serial
	for stage in ${VERIFIED_STAGES[@]}; do
		if [[ -f "build/${stage}.stage" ]]; then
			newins "build/${stage}.stage" "${stage}.stage"
			newins "build_serial/${stage}.stage" "${stage}.stage.serial"
		fi
	done

	OPROM=$( awk 'BEGIN{FS="\""} /CONFIG_VGA_BIOS_FILE=/ { print $2 }' \
		${FILESDIR}/configs/config.${board} )
	CBFSOPROM=pci$( awk 'BEGIN{FS="\""} /CONFIG_VGA_BIOS_ID=/ { print $2 }' \
		${FILESDIR}/configs/config.${board} ).rom
	FSP=$( awk 'BEGIN{FS="\""} /CONFIG_FSP_FILE=/ { print $2 }' \
		${FILESDIR}/configs/config.${board} )
	if [[ -n "${FSP}" ]]; then
		newins ${FSP} fsp.bin
	fi
	if [[ -n "${OPROM}" ]]; then
		newins ${OPROM} ${CBFSOPROM}
	fi
	if use memmaps; then
		for mapfile in build/cbfs/fallback/*.map
		do
			doins $mapfile
		done
	fi
	newins .config coreboot.config
}

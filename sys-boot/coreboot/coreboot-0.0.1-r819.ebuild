# Copyright (c) 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT=("e69ee5ec57e41a51cfc8b5ab69ed1220766479c3" "c1a96b0f42673494a4378876e03c394c30b75a83" "5f33d05693f14d13a532b465ac01bfcc6134cb61")
CROS_WORKON_TREE=("d3eefe8c37ebf54ee96e45fb9e2631f655eb25b5" "20c5fed94d3e2e20e0aff42a1df28d8368688a09" "9094872ac0fbbd14102aa98872b35d298bafdf91")
CROS_WORKON_PROJECT=(
	"chromiumos/third_party/coreboot"
	"chromiumos/platform/vboot_reference"
	"chromiumos/third_party/coreboot/blobs"
)
CROS_WORKON_LOCALNAME=(
	"coreboot"
	"../platform/vboot_reference"
	"coreboot/3rdparty"
)
CROS_WORKON_DESTDIR=(
	"${S}"
	"${S}/vboot_reference"
	"${S}/3rdparty"
)

inherit cros-board cros-workon toolchain-funcs

DESCRIPTION="coreboot firmware"
HOMEPAGE="http://www.coreboot.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="em100-mode fsp memmaps mocktpm quiet-cb rmt vmx"

PER_BOARD_BOARDS=(
	bayleybay beltino bolt butterfly cyan daisy falco fox gizmo glados link
	lumpy nyan panther parrot peppy rambi samus sklrvp slippy stout stout32
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

	# Extract the coreboot romstage file into the build dir.
	cbfstool "${builddir}/coreboot.rom" extract \
		-n "fallback/romstage" \
		-f "${builddir}/romstage.stage" || die

	# Extract the coreboot ramstage file into the build dir.
	cbfstool "${builddir}/coreboot.rom" extract \
		-n "fallback/ramstage" \
		-f "${builddir}/ramstage.stage" || die

	# Extract the reference code stage into the build dir if present.
	cbfstool "${builddir}/coreboot.rom" extract \
		-n "fallback/refcode" \
		-f "${builddir}/refcode.stage" || true
}

src_compile() {
	tc-export CC

	# Set KERNELREVISION (really coreboot revision) to the ebuild revision
	# number followed by a dot and the first seven characters of the git
	# hash. The name is confusing but consistent with the coreboot
	# Makefile.
	local sha1v="${VCSID/*-/}"
	export KERNELREVISION=".${PV}.${sha1v:0:7}"

	# Firmware related binaries are compiled with a 32-bit toolchain
	# on 64-bit platforms
	if use amd64 ; then
		export CROSS_COMPILE="i686-pc-linux-gnu-"
		export CC="${CROSS_COMPILE}gcc"
	else
		export CROSS_COMPILE=${CHOST}-
	fi

	if use arm || use arm64 ; then
		extra_flags="-ffunction-sections"
		# Export the known cross compilers for ARM systems. Include
		# both v7a and 64-bit armv8 compilers so there isn't a reliance
		# on what the default profile is for exporting a compiler. The
		# reasoning is that the firmware may need both to build and
		# and boot.
		export CROSS_COMPILE_aarch64="aarch64-cros-linux-gnu-"
		export CROSS_COMPILE_arm="armv7a-cros-linux-gnu-"
	fi

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
	newins "build/romstage.stage" romstage.stage
	newins "build_serial/romstage.stage" romstage.stage.serial
	newins "build/ramstage.stage" ramstage.stage
	newins "build_serial/ramstage.stage" ramstage.stage.serial
	if [[ -f "build/refcode.stage" ]]; then
		newins "build/refcode.stage" refcode.stage
		newins "build_serial/refcode.stage" refcode.stage.serial
	fi
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

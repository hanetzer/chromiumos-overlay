# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: cros-coreboot.eclass
# @MAINTAINER:
# The Chromium OS Authors
# @BLURB: Unifies logic for building coreboot images for Chromium OS.

[[ ${EAPI} != "4" ]] && die "Only EAPI=4 is supported"

inherit cros-board toolchain-funcs

DESCRIPTION="coreboot firmware"
HOMEPAGE="http://www.coreboot.org"
LICENSE="GPL-2"
SLOT="0"
IUSE="em100-mode fwserial memmaps quiet-cb rmt"


RDEPEND="!sys-boot/chromeos-coreboot"

# Dependency shared by x86 and amd64.
DEPEND_X86="
	sys-power/iasl
	sys-boot/chromeos-mrc
	sys-apps/coreboot-utils
	"

DEPEND_ARM="
	sys-apps/coreboot-utils
	"

DEPEND="x86? ($DEPEND_X86)
	amd64? ($DEPEND_X86)
	arm? ($DEPEND_ARM)
	"

cros-coreboot_pre_src_prepare() {
	rm -rf 3rdparty
	local board=$(get_current_board_with_variant)

	if [[ -s "${FILESDIR}"/config ]]; then
		# Attempt to get config from overlay first
		cp -v "${FILESDIR}"/config .config
	elif [[ -s "configs/config.${board}" ]]; then
		# Otherwise use config from coreboot tree
		cp -v "configs/config.${board}" .config
	fi

	if use rmt; then
		echo "CONFIG_MRC_RMT=y" >> .config
	fi
	if use fwserial; then
		elog "   - enabling firmware serial console"
		cat "configs/fwserial.${board}" >> .config || die
	fi

	if [[ -d "${FILESDIR}"/3rdparty ]]; then
		cp -pPR "${FILESDIR}"/3rdparty ./ || die
	fi
}

cros-coreboot_src_compile() {
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

	elog "Toolchain:\n$(sh util/xcompile/xcompile)\n"

	if use quiet-cb; then
		# Suppress console spew if requested.
		cat >> .config <<EOF
CONFIG_DEFAULT_CONSOLE_LOGLEVEL=3
# CONFIG_DEFAULT_CONSOLE_LOGLEVEL_8 is not set
CONFIG_DEFAULT_CONSOLE_LOGLEVEL_3=y
EOF
	fi

	yes "" | emake oldconfig
	emake

	# Modify firmware descriptor if building for the EM100 emulator.
	if use em100-mode; then
		ifdtool --em100 "build/coreboot.rom" || die
		mv "build/coreboot.rom"{.new,} || die
	fi

	# Extract the coreboot ramstage file into the build dir.
	cbfstool "build/coreboot.rom" extract \
		-n "fallback/coreboot_ram" \
		-f "build/coreboot_ram.stage" || die

	# Extract the reference code stage into the build dir if present.
	cbfstool "build/coreboot.rom" extract \
		-n "fallback/refcode" \
		-f "build/refcode.stage" || true

	# Build cbmem for the target
	cd util/cbmem
	emake clean
	CROSS_COMPILE="${CHOST}-" emake
}

cros-coreboot_src_install() {
	local mapfile
	local board=$(get_current_board_with_variant)
	dobin util/cbmem/cbmem
	insinto /firmware
	newins "build/coreboot.rom" coreboot.rom
	newins "build/coreboot_ram.stage" coreboot_ram.stage
	if [[ -f "build/refcode.stage" ]]; then
		newins "build/refcode.stage" refcode.stage
	fi
	OPROM=$( awk 'BEGIN{FS="\""} /CONFIG_VGA_BIOS_FILE=/ { print $2 }' \
		configs/config.${board} )
	CBFSOPROM=pci$( awk 'BEGIN{FS="\""} /CONFIG_VGA_BIOS_ID=/ { print $2 }' \
		configs/config.${board} ).rom
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

EXPORT_FUNCTIONS src_compile src_install pre_src_prepare

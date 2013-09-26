# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: cros-coreboot.eclass
# @MAINTAINER:
# The Chromium OS Authors
# @BLURB: Unifies logic for building coreboot images for Chromium OS.

[[ ${EAPI} != "4" ]] && die "Only EAPI=4 is supported"

inherit toolchain-funcs

DESCRIPTION="coreboot firmware"
HOMEPAGE="http://www.coreboot.org"
LICENSE="GPL-2"
SLOT="0"
IUSE="em100-mode memmaps"


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

# @ECLASS-VARIABLE: COREBOOT_BOARD
# @DESCRIPTION:
# Coreboot Configuration name.
: ${COREBOOT_BOARD:=}

# @ECLASS-VARIABLE: COREBOOT_BUILD_ROOT
# @DESCRIPTION:
# Build directory root
: ${COREBOOT_BUILD_ROOT:=}

[[ -z ${COREBOOT_BOARD} ]] && die "COREBOOT_BOARD must be set"
[[ -z ${COREBOOT_BUILD_ROOT} ]] && die "COREBOOT_BUILD_ROOT must be set"

cros-coreboot_pre_src_prepare() {
	rm -rf 3rdparty

	if [[ -s "${FILESDIR}"/config ]]; then
		# Attempt to get config from overlay first
		cp -v "${FILESDIR}"/config .config
	elif [[ -s "configs/config.${COREBOOT_BOARD}" ]]; then
		# Otherwise use config from coreboot tree
		cp -v "configs/config.${COREBOOT_BOARD}" .config
	fi

	if [[ -d "${FILESDIR}"/3rdparty ]]; then
		cp -pPR "${FILESDIR}"/3rdparty ./ || die
	fi
}

cros-coreboot_src_compile() {
	tc-export CC
	local board="${COREBOOT_BOARD}"
	local build_root="${COREBOOT_BUILD_ROOT}"

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
	yes "" | emake obj="${build_root}" oldconfig
	emake obj="${build_root}"

	# Modify firmware descriptor if building for the EM100 emulator.
	if use em100-mode; then
		ifdtool --em100 "${build_root}/coreboot.rom" || die
		mv "${build_root}/coreboot.rom"{.new,} || die
	fi

	# Extract the coreboot ramstage file into the build_root.
	cbfstool "${build_root}/coreboot.rom" extract \
		-n "fallback/coreboot_ram" \
		-f "${build_root}/coreboot_ram.stage" || die

	# Build cbmem for the target
	cd util/cbmem
	emake clean
	CROSS_COMPILE="${CHOST}-" emake
}

cros-coreboot_src_install() {
	local mapfile
	dobin util/cbmem/cbmem
	insinto /firmware
	newins "${COREBOOT_BUILD_ROOT}/coreboot.rom" coreboot.rom
	newins "${COREBOOT_BUILD_ROOT}/coreboot_ram.stage" coreboot_ram.stage
	OPROM=$( awk 'BEGIN{FS="\""} /CONFIG_VGA_BIOS_FILE=/ { print $2 }' \
		configs/config.${COREBOOT_BOARD} )
	CBFSOPROM=pci$( awk 'BEGIN{FS="\""} /CONFIG_VGA_BIOS_ID=/ { print $2 }' \
		configs/config.${COREBOOT_BOARD} ).rom
	if [[ -n "${OPROM}" ]]; then
		newins ${OPROM} ${CBFSOPROM}
	fi
	if use memmaps; then
		for mapfile in ${COREBOOT_BUILD_ROOT}/cbfs/fallback/*.map
		do
			doins $mapfile
		done
	fi
	newins .config coreboot.config
}

EXPORT_FUNCTIONS src_compile src_install pre_src_prepare

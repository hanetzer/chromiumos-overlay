# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: cros-coreboot.eclass
# @MAINTAINER:
# The Chromium OS Authors
# @BLURB: Unifies logic for building coreboot images for Chromium OS.

[[ ${EAPI} != "4" ]] && die "Only EAPI=4 is supported"

inherit toolchain-funcs

DESCRIPTION="coreboot x86 firmware"
HOMEPAGE="http://www.coreboot.org"
LICENSE="GPL-2"
SLOT="0"
IUSE="em100-mode"


RDEPEND=""

DEPEND="sys-power/iasl
	sys-apps/coreboot-utils
	sys-boot/chromeos-mrc
	"

# @ECLASS-VARIABLE: COREBOOT_BOARD
# @DESCRIPTION:
# Coreboot Configuration name.
: ${COREBOOT_BOARD:=}

# @ECLASS-VARIABLE: COREBOOT_BOARD_ROOT
# @DESCRIPTION:
# Directory within 3rdparty/mainboard appropriate for selected board.
: ${COREBOOT_BOARD_ROOT:=}

# @ECLASS-VARIABLE: COREBOOT_BUILD_ROOT
# @DESCRIPTION:
# Build directory root
: ${COREBOOT_BUILD_ROOT:=}

[[ -z ${COREBOOT_BOARD} ]] && die "COREBOOT_BOARD must be set"
[[ -z ${COREBOOT_BOARD_ROOT} ]] && die "COREBOOT_BOARD_ROOT must be set"
[[ -z ${COREBOOT_BUILD_ROOT} ]] && die "COREBOOT_BUILD_ROOT must be set"

cros-coreboot_src_compile() {
	tc-export CC
	local board="${COREBOOT_BOARD}"
	local build_root="${COREBOOT_BUILD_ROOT}"
	local board_root="3rdparty/mainboard/${COREBOOT_BOARD_ROOT}"
	local flash_descriptor_file=''

	cp configs/config.${board} .config

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
		export CC="${CROSS_COMPILE}-gcc"
	else
		export CROSS_COMPILE=${CHOST}-
	fi

	elog "Toolchain:\n$(sh util/xcompile/xcompile)\n"
	emake obj="${build_root}" oldconfig
	emake obj="${build_root}"

	# build a firmware descriptor image skeleton if there is a firmware
	# descriptor available.
	flash_descriptor_file=${board_root}/descriptor.bin
	if [[ -r ${flash_descriptor_file} ]]; then
		elog "Creating Intel Firmware Descriptor skeleton."
		# For now we assume all Sandybridge/Ivybridge systems
		# come with an 8MB flash part, and the BIOS image lives at the
		# end of the IFD image.
		dd if="${flash_descriptor_file}" \
			of="${build_root}/skeleton.bin" bs=8M conv=sync

		# Modify firmware descriptor if building for the EM100 emulator.
		if use em100-mode; then
			ifdtool --em100 "${build_root}/skeleton.bin" || die
			mv "${build_root}/skeleton.bin"{.new,} || die
		fi

		if [[ -r ${board_root}/gbe.bin ]]; then
			elog "   - adding ${board_root}/gbe.bin"
			ifdtool -i "GbE:${board_root}/gbe.bin" \
				"${build_root}/skeleton.bin" || die
			mv "${build_root}/skeleton.bin"{.new,} || die
		fi

		if [[ -r ${board_root}/me.bin ]]; then
			elog "   - adding ${board_root}/me.bin"
			ifdtool -i "ME:${board_root}/me.bin" \
				"${build_root}/skeleton.bin" || die
			mv "${build_root}/skeleton.bin"{.new,} || die
		fi
	else
		die "${flash_descriptor_file} not found"
	fi
}

cros-coreboot_src_install() {
	insinto /firmware
	newins "${COREBOOT_BUILD_ROOT}/coreboot.rom" coreboot.rom
	if [[ -r ${COREBOOT_BUILD_ROOT}/skeleton.bin ]]; then
		doins "${COREBOOT_BUILD_ROOT}/skeleton.bin"
	fi
}

EXPORT_FUNCTIONS src_compile src_install

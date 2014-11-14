# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_PROJECT="chromiumos/third_party/seabios"
CROS_WORKON_LOCALNAME="seabios"

inherit toolchain-funcs cros-workon

DESCRIPTION="Open Source implementation of X86 BIOS"
HOMEPAGE="http://www.coreboot.org/SeaBIOS"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND=""
DEPEND="
	sys-apps/coreboot-utils
	sys-boot/coreboot
"

# Directory where the generated files are looked for and placed.
CROS_FIRMWARE_IMAGE_DIR="/firmware"
CROS_FIRMWARE_ROOT="${SYSROOT%/}${CROS_FIRMWARE_IMAGE_DIR}"

create_seabios_cbfs() {
	local suffix="$1"
	local oprom=$(echo "${CROS_FIRMWARE_ROOT}"/pci????,????.rom)
	local seabios_cbfs="seabios.cbfs${suffix}"
	local cbfs_size=$(( 2 * 1024 * 1024 ))
	local bootblock="${T}/bootblock"

	_cbfstool() { set -- cbfstool "$@"; echo "$@"; "$@" || die "'$*' failed"; }

	# Create empty CBFS
	_cbfstool ${seabios_cbfs} create -s ${cbfs_size} -m x86
	# Add SeaBIOS binary to CBFS
	_cbfstool ${seabios_cbfs} add-payload -f out/bios.bin.elf -n payload -c lzma
	# Add VGA option rom to CBFS
	_cbfstool ${seabios_cbfs} add -f "${oprom}" -n $(basename "${oprom}") -t optionrom
	# Add additional configuration
	_cbfstool ${seabios_cbfs} add -f chromeos/links -n links -t raw
	_cbfstool ${seabios_cbfs} add -f chromeos/bootorder -n bootorder -t raw
	_cbfstool ${seabios_cbfs} add -f chromeos/etc/boot-menu-key -n etc/boot-menu-key -t raw
	_cbfstool ${seabios_cbfs} add -f chromeos/etc/boot-menu-message -n etc/boot-menu-message -t raw
	_cbfstool ${seabios_cbfs} add -f chromeos/etc/boot-menu-wait -n etc/boot-menu-wait -t raw
	# Print CBFS inventory
	_cbfstool ${seabios_cbfs} print
}

_emake() {
	emake \
		CROSS_PREFIX="${CHOST}-" \
		LD="$(tc-getLD).bfd" \
		CC="$(tc-getCC) -fuse-ld=bfd" \
		"$@"
}

src_compile() {
	local config="chromeos/default.config"

	_emake defconfig KCONFIG_DEFCONFIG="${config}"
	_emake
	create_seabios_cbfs ""
	_emake clean

	echo "CONFIG_DEBUG_SERIAL=y" >> "${config}"
	_emake defconfig KCONFIG_DEFCONFIG="${config}"
	_emake
	create_seabios_cbfs ".serial"
}

src_install() {
	insinto /firmware
	doins out/bios.bin.elf seabios.cbfs seabios.cbfs.serial
}

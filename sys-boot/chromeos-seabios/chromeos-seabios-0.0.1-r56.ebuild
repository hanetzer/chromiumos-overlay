# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="09693bcbd087c8e0bd4ac33833cfc11323b9f633"
CROS_WORKON_TREE="94946f1f4490d78b85222282a8a20541f377b5cd"
CROS_WORKON_PROJECT="chromiumos/third_party/seabios"
CROS_WORKON_LOCALNAME="seabios"

inherit toolchain-funcs cros-workon

DESCRIPTION="Open Source implementation of X86 BIOS"
HOMEPAGE="http://www.coreboot.org/SeaBIOS"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="fwserial"

RDEPEND=""
DEPEND="
	sys-apps/coreboot-utils
	sys-boot/coreboot
"

# Directory where the generated files are looked for and placed.
CROS_FIRMWARE_IMAGE_DIR="/firmware"
CROS_FIRMWARE_ROOT="${SYSROOT%/}${CROS_FIRMWARE_IMAGE_DIR}"

create_seabios_cbfs() {
	local oprom=$(echo "${CROS_FIRMWARE_ROOT}"/pci????,????.rom)
	local seabios_cbfs=seabios.cbfs
	local cbfs_size=$(( 2 * 1024 * 1024 ))
	local bootblock="${T}/bootblock"

	_cbfstool() { set -- cbfstool "$@"; echo "$@"; "$@" || die "'$*' failed"; }

	# Create a dummy bootblock to make cbfstool happy
	truncate -s 64 "${bootblock}"
	# Create empty CBFS
	_cbfstool ${seabios_cbfs} create -s ${cbfs_size} -B "${bootblock}" -m x86
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
	# Fix up CBFS to live at 0xffc00000. The last four bytes of a CBFS
	# image are a pointer to the CBFS master header. Per default a CBFS
	# lives at 4G - rom size, and the CBFS master header ends up at
	# 0xffffffa0. However our CBFS lives at 4G-4M and is 2M in size, so
	# the CBFS master header is at 0xffdfffa0 instead. The two lines
	# below correct the according byte in that pointer to make all CBFS
	# parsing code happy. In the long run we should fix cbfstool and
	# remove this workaround.
	echo -ne \\0737 | dd of=${seabios_cbfs} \
			seek=$(( cbfs_size - 2 )) bs=1 conv=notrunc
}

_emake() {
	emake \
		CROSS_PREFIX="${CHOST}-" \
		LD="$(tc-getLD).bfd" \
		CC="$(tc-getCC) -fuse-ld=bfd" \
		"$@"
}

src_configure() {
	local config="chromeos/default.config"
	if use fwserial; then
	    echo "CONFIG_DEBUG_SERIAL=y" >> "${config}"
	fi
	_emake defconfig KCONFIG_DEFCONFIG="${config}"
}

src_compile() {
	_emake
	create_seabios_cbfs
}

src_install() {
	insinto /firmware
	doins out/bios.bin.elf seabios.cbfs
}

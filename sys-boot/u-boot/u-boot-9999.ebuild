# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit cros-workon toolchain-funcs

DESCRIPTION="Das U-Boot boot loader"
HOMEPAGE="http://www.denx.de/wiki/U-Boot"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~arm"
IUSE=""

# U-Boot should have no runtime dependencies; everything it depends on must be
# statically linked.
RDEPEND=""
DEPEND="chromeos-base/vboot_reference"

u_boot=${CHROMEOS_U_BOOT:-"files"}
config=${CHROMEOS_U_BOOT_CONFIG:-"versatile_config"}

#
# Strip the ebuild directory to construct a valid CROS_WORKON_SUBDIR.  This can
# be removed once all of the overlay make.confs specify CHROMEOS_U_BOOT without
# the u-boot directory prefixed.
#
CROS_WORKON_SUBDIR="${u_boot#u-boot/}"

src_configure() {
	elog "Using U-Boot config: ${config}"

	emake distclean
	emake \
	      ARCH=$(tc-arch-kernel) \
	      CROSS_COMPILE="${CHOST}-" \
	      USE_PRIVATE_LIBGCC=yes \
	      ${config} || die "U-Boot configuration failed"
}

src_compile() {
	tc-getCC
	tc-getSTRIP

	emake \
	      ARCH=$(tc-arch-kernel) \
	      CROSS_COMPILE="${CHOST}-" \
	      USE_PRIVATE_LIBGCC=yes \
	      HOSTCC=${CC} \
	      HOSTSTRIP=${STRIP} \
	      VBOOT="${ROOT}/usr" \
	      all || die "U-Boot compile failed"
}

src_install() {
	dodir /u-boot

	insinto /u-boot
	doins u-boot.bin || die

	dobin "${S}"/tools/mkimage || die
}

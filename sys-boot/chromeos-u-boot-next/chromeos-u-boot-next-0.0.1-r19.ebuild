# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="5d40e963c4c451e681f2b454d3d0e4451389ef2a"

inherit toolchain-funcs

DESCRIPTION="Das U-Boot boot loader"
HOMEPAGE="http://www.denx.de/wiki/U-Boot"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="arm"
IUSE=""
PROVIDE="virtual/u-boot"

RDEPEND=""
DEPEND="chromeos-base/vboot_reference
	!sys-boot/u-boot"

CROS_WORKON_PROJECT="u-boot-next"
CROS_WORKON_LOCALNAME="u-boot-next"
CROS_WORKON_SUBDIR="files"

# This must be inherited *after* EGIT/CROS_WORKON variables defined
inherit cros-workon

src_configure() {
	local config=${CHROMEOS_U_BOOT_CONFIG}

	elog "Using U-Boot config: ${config}"

	emake \
	      ARCH=$(tc-arch-kernel) \
	      CROSS_COMPILE="${CHOST}-" \
	      distclean
	emake \
	      ARCH=$(tc-arch-kernel) \
	      CROSS_COMPILE="${CHOST}-" \
	      USE_PRIVATE_LIBGCC=yes \
	      ${config} || die "U-Boot configuration failed"
}

src_compile() {
	tc-getCC

	emake \
	      ARCH=$(tc-arch-kernel) \
	      CROSS_COMPILE="${CHOST}-" \
	      USE_PRIVATE_LIBGCC=yes \
	      HOSTCC=${CC} \
	      HOSTSTRIP=true \
              VBOOT="${ROOT}/usr" \
	      all || die "U-Boot compile failed"
}

src_install() {
	dodir /u-boot

	insinto /u-boot
	doins u-boot.bin || die

	dobin "${S}"/tools/mkimage || die
}

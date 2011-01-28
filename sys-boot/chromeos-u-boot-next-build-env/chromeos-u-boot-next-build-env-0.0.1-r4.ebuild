# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="7ac0f9d3078b83c6cea8c4bf5c0983bffc44b3b1"

inherit toolchain-funcs

# Export build environment/variables for build libraries
# that will be linked with u-boot

DESCRIPTION="Export U-Boot build environment"
HOMEPAGE="http://www.denx.de/wiki/U-Boot"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="arm"
IUSE=""
PROVIDE="virtual/u-boot"

RDEPEND=""
DEPEND=""

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
	      u-boot-cflags.mk || die "U-Boot generate config failed"
}

src_install() {
	dodir /u-boot

	insinto /u-boot
	doins u-boot-cflags.mk || die
}

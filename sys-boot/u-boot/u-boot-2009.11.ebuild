# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit toolchain-funcs

DESCRIPTION="Das U-Boot boot loader"
HOMEPAGE="http://www.denx.de/wiki/U-Boot"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="arm"
IUSE=""

DEPEND=""
RDEPEND=""

src_unpack() {
	local files="${CHROMEOS_ROOT}/src/third_party/u-boot/files"
	elog "Using u-boot dir: $files"
	mkdir -p "${S}"
	cp -a "${files}"/* "${S}" || die "U-Boot copy failed"
}

src_configure() {
	emake \
	      ARCH=$(tc-arch-kernel) \
	      CROSS_COMPILE="${CHOST}-" \
	      USE_PRIVATE_LIBGCC=yes \
	      QSD8x50_surf_config || die "U-Boot configuration failed"
}

src_compile() {
	emake \
	      ARCH=$(tc-arch-kernel) \
	      CROSS_COMPILE="${CHOST}-" \
	      USE_PRIVATE_LIBGCC=yes \
	      all || die "U-Boot compile failed"
}

src_install() {
	      dodir /u-boot

	      cp -a "${S}"/u-boot.bin "${D}"/u-boot/
}

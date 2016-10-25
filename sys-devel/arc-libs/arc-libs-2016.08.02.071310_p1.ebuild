# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="Ebuild for Android Libs (libc, libcxx, etc)."
SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${P}.tar.gz"

LICENSE="GPL-3 LGPL-3 GPL-3"
SLOT="0"
KEYWORDS="-* amd64"
IUSE=""

S=${WORKDIR}
INSTALL_DIR="/opt/android"


# These prebuilts are already properly stripped.
RESTRICT="strip"
QA_PREBUILT="*"

clobber() {
	touch "$1"
	tee "$1" > /dev/null
}

create_pkgconfig_wrapper() {
	local IMAGE_DIR="${D}/${INSTALL_DIR}"
	local TARGET="${IMAGE_DIR}/pkg-config-arc"
	clobber "${TARGET}" <<EOF
#!/bin/bash

PKG_CONFIG_LIBDIR="${INSTALL_DIR}/pkgconfig"
export PKG_CONFIG_LIBDIR

export PKG_CONFIG_SYSROOT_DIR="${INSTALL_DIR}/\$1"

# Portage will get confused and try to "help" us by exporting this.
# Undo that logic.
unset PKG_CONFIG_PATH

exec pkg-config "\${@:2}"
EOF
	chmod a+rx "${TARGET}"
}

src_install() {
	dodir ${INSTALL_DIR}
	cp -pPR * "${D}/${INSTALL_DIR}/" || die
	cp -pPR "${FILESDIR}/pkgconfig" "${D}/${INSTALL_DIR}/" || die
	create_pkgconfig_wrapper
}

# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libpciaccess/libpciaccess-0.12.902.ebuild,v 1.1 2011/12/19 01:39:15 chithanh Exp $

EAPI="5"
SLOT="0"

P=${P#"arc-"}
PN=${PN#"arc-"}
S="${WORKDIR}/${P}"

XORG_MULTILIB=yes
inherit xorg-2 arc-build

DESCRIPTION="Library providing generic access to the PCI bus and devices"
KEYWORDS="*"
IUSE="minimal zlib"

DEPEND=""
RDEPEND="${DEPEND}"

PATCHES=(
	"${FILESDIR}/nodevport.patch"
	"${FILESDIR}/nodevport-2.patch"
)

pkg_setup() {
	# FIXME(tfiga): Could inherit arc-build invoke this implicitly?
	arc-build-select-gcc

	xorg-2_pkg_setup

	XORG_CONFIGURE_OPTIONS=(
		"$(use_with zlib)"
		"--with-pciids-path=${EPREFIX}/usr/share/misc"
		"--prefix=${ARC_PREFIX}/vendor"
	)
}

multilib_src_install() {
	default
}
# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-proto/xextproto/xextproto-7.2.0.ebuild,v 1.3 2011/03/16 16:14:15 scarabeus Exp $

EAPI=4

XORG_DOC=doc
inherit xorg-2

DESCRIPTION="X.Org XExt protocol headers"

KEYWORDS="*"
IUSE=""

RDEPEND="!<x11-libs/libXext-1.0.99"
DEPEND="${RDEPEND}"

pkg_setup() {
	xorg-2_pkg_setup

	CONFIGURE_OPTIONS="
		$(use_with doc xmlto)
		--without-fop
	"
}

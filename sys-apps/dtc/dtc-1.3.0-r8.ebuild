# Copyright 1999-2011 Gentoo Foundation
# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/dtc/dtc-1.3.0.ebuild,v 1.1 2011/06/15 21:19:11 flameeyes Exp $
CROS_WORKON_COMMIT="d290c792873288a78e5ea61558b23d446e48c0ab"
CROS_WORKON_TREE="3790230bf2c96ed5a63f8b510a087047e547a52c"

EAPI=4
CROS_WORKON_PROJECT="chromiumos/third_party/dtc"
CROS_WORKON_LOCALNAME="dtc"

inherit toolchain-funcs cros-workon

DESCRIPTION="Open Firmware device-tree compiler"
HOMEPAGE="http://www.t2-project.org/packages/dtc.html"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ppc ppc64 x86"
IUSE=""

RDEPEND=""
DEPEND="sys-devel/flex
	sys-devel/bison"

src_compile() {
	tc-export AR CC
	emake PREFIX="/usr" LIBDIR="/usr/$(get_libdir)"
}

src_test() {
	emake check
}

src_install() {
	emake DESTDIR="${D}" PREFIX="/usr" LIBDIR="/usr/$(get_libdir)" \
		 install
	dodoc Documentation/manual.txt
}

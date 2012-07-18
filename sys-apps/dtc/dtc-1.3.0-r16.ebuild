# Copyright 1999-2011 Gentoo Foundation
# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/dtc/dtc-1.3.0.ebuild,v 1.1 2011/06/15 21:19:11 flameeyes Exp $
CROS_WORKON_COMMIT=42c511eb3e379e48b2dc9816fdb7abe790b47687
CROS_WORKON_TREE="0d5247c1400742a5a686796b5ce865d64c296c3a"

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

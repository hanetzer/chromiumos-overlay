# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/crossdev/crossdev-20101011.ebuild,v 1.1 2010/10/11 09:00:42 vapier Exp $

inherit eutils

EAPI="3"

if [[ ${PV} == "99999999" ]] ; then
	EGIT_REPO_URI="git://git.overlays.gentoo.org/proj/crossdev.git"
	inherit git
	SRC_URI=""
	#KEYWORDS=""
else
	SRC_URI="mirror://gentoo/${P}.tar.xz
		http://dev.gentoo.org/~vapier/dist/${P}.tar.xz"
	KEYWORDS="~alpha amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
fi

DESCRIPTION="Gentoo Cross-toolchain generator"
HOMEPAGE="http://www.gentoo.org/"

LICENSE="GPL-2"
SLOT="0"
IUSE=""

RDEPEND=">=sys-apps/portage-2.1
	app-shells/bash
	!sys-devel/crossdev-wrappers"
DEPEND="app-arch/xz-utils"

src_unpack() {
	unpack ${A}
	cd "${S}"
	install --mode=0644 "${FILESDIR}"/linux-gnu "${S}"/wrappers/site
	epatch "${FILESDIR}"/${PN}-cross-pkg-config-sysroot.patch
	epatch "${FILESDIR}"/${PN}-no-cross-fix-root.patch
	epatch "${FILESDIR}"/${PN}-arm-dbus-fix.patch
	epatch "${FILESDIR}"/${PN}-metadata.patch
	epatch "${FILESDIR}"/${PN}-multilib.patch
	epatch "${FILESDIR}"/${PN}-multilib2.patch
	epatch "${FILESDIR}"/${PN}-multilib3.patch
	epatch "${FILESDIR}"/${PN}-multilib4.patch
	epatch "${FILESDIR}"/${PN}-no-inherit-toolchain-check.patch
	# mirrors upstream commit e6597f08a4deef639c038e07a47c5ed810c9f556
	rm -rf wrappers/etc/portage/env
}

src_install() {
	emake install DESTDIR="${D}" || die
}

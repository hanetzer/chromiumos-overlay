# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-boot/syslinux/syslinux-3.83.ebuild,v 1.3 2010/02/26 12:10:54 fauli Exp $

inherit eutils flag-o-matic

DESCRIPTION="SysLinux, IsoLinux and PXELinux bootloader"
HOMEPAGE="http://syslinux.zytor.com/"
SRC_URI="mirror://kernel/linux/utils/boot/syslinux/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="-* amd64 x86"
IUSE=""

RDEPEND="sys-fs/mtools
		dev-perl/Crypt-PasswdMD5
		dev-perl/Digest-SHA1"
DEPEND="${RDEPEND}
	dev-lang/nasm"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-3.72-nopie.patch
	# Don't prestrip, makes portage angry
	epatch "${FILESDIR}"/${PN}-3.72-nostrip.patch

	# Don't try to build win32/syslinux.exe
	epatch "${FILESDIR}/"${P}-disable_win32.patch

	# Disable the text banner for quieter boot.
	epatch "${FILESDIR}/"${P}-disable_banner.patch

	# Disable the blinking cursor as early as possible.
	epatch "${FILESDIR}/"${P}-disable_cursor.patch

	rm -f gethostip #bug 137081
}

src_compile() {
	# By default, syslinux wants you to use pre-built binaries
	# and only compile part of the package. Since we want to rebuild
	# everything from scratch we need to remove the prebuilts or else
	# some things don't get built with standard make.
	emake spotless || die "make spotless failed"

	# The syslinux build can't tolerate "-Wl,-O*"
	filter-ldflags -Wl,-O1 -Wl,-O2 -Wl,-Os

	emake || die "make failed"
}

src_install() {
	emake INSTALLSUBDIRS=utils INSTALLROOT="${D}" MANDIR=/usr/share/man install || die
	dodoc README NEWS TODO doc/*
}

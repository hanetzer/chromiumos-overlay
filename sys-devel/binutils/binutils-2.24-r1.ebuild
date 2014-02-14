# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/binutils/binutils-2.24-r1.ebuild,v 1.2 2014/01/13 19:04:22 vapier Exp $

PATCHVER="1.2"
ELF2FLT_VER=""
inherit toolchain-binutils

KEYWORDS=""

PATCHES=( "${FILESDIR}/save-temps.patch" )

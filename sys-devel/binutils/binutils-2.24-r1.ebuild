# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/binutils/binutils-2.24-r1.ebuild,v 1.2 2014/01/13 19:04:22 vapier Exp $

PATCHVER="1.2"
ELF2FLT_VER=""
inherit toolchain-binutils

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 -amd64-fbsd -sparc-fbsd -x86-fbsd"

PATCHES=( "${FILESDIR}/save-temps.patch" )

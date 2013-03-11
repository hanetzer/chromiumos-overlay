# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/gdb/gdb-7.5.1.ebuild,v 1.13 2013/02/21 16:08:27 ago Exp $

DESCRIPTION="dummy upgrade ebuild for SLOT=${CTARGET}"

KEYWORDS="amd64 arm x86"

if [[ ${CATEGORY} == cross-* ]] ; then
	SLOT=${CATEGORY/cross-}
	PDEPEND=">=${CATEGORY}/gdb-7.5"
else
	SLOT="0"
fi

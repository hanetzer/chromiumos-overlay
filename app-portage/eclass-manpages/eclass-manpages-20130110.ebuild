# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-portage/eclass-manpages/eclass-manpages-20130110.ebuild,v 1.2 2013/01/10 17:21:58 vapier Exp $

EAPI="4"

DESCRIPTION="collection of Gentoo eclass manpages"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

S=${WORKDIR}

genit() {
	local e=${1:-${ECLASSDIR}}
	[[ -d ${e} ]] || return 0
	einfo "Generating man pages from: ${e}"
	env ECLASSDIR=${e} "${FILESDIR}"/eclass-to-manpage.sh || die
}

src_compile() {
	# First process any eclasses found in overlays.  Then process
	# the main eclassdir last so that its output will clobber anything
	# that might have come from overlays.  Main tree wins!
	local o
	for o in ${PORTDIR_OVERLAY} ; do
		genit "${o}/eclass"
	done
	genit
}

src_install() {
	doman *.5
}

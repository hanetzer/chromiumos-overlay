# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit font

DESCRIPTION="Caladea font for Chrom*OS by Huerta Tipografia"
SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"
IUSE=""

FONT_SUFFIX="ttf"
FONT_S="${S}"
FONTDIR="/usr/share/fonts/crosextra"


# Only installs fonts
RESTRICT="strip binchecks"

src_install() {
        # call src_install() in font.eclass.
	font_src_install
}

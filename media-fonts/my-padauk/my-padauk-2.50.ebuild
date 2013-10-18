# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit font

DESCRIPTION="Padauk font for Myanmar"
SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${P}.tar.gz"
HOMEPAGE="http://scripts.sil.org/cms/scripts/page.php?site_id=nrsi&id=padauk"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"
IUSE=""

FONT_SUFFIX="ttf"
FONT_S="${S}"
FONTDIR="/usr/share/fonts/my-padauk"


# Only installs fonts
RESTRICT="strip binchecks"

src_install() {
        # call src_install() in font.eclass.
        font_src_install
}

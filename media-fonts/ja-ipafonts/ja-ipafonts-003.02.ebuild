# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-fonts/ja-ipafonts/ja-ipafonts-003.01.ebuild,v 1.5 2009/10/07 20:54:14 maekke Exp $

# Chromium OS Changes:
# - Changed FONT_SUFFIX from otf to ttf since a file extension of IPA has changed.
# - Define src_install() to install IPA_Font_License_Agreement_v1.0.txt. This is required by the license.
#   We can't use the DOCS variable below since these DOCS will be automatically removed on Chromium OS.

inherit font

MY_P="IPAfont${PV/.}"
DESCRIPTION="Japanese TrueType fonts developed by IPA (Information-technology Promotion Agency, Japan)"
HOMEPAGE="http://ossipedia.ipa.go.jp/ipafont/"
SRC_URI="mirror://gentoo/${MY_P}.zip"

LICENSE="IPAfont"
SLOT="0"
KEYWORDS="alpha amd64 arm ~hppa ~ia64 ppc ~ppc64 ~s390 ~sh x86 ~x86-fbsd"
IUSE=""

S="${WORKDIR}/${MY_P}"
FONT_SUFFIX="ttf"
FONT_S="${S}"

DOCS="Readme*.txt"

# Only installs fonts
RESTRICT="strip binchecks"

src_install() {
        # call src_install() in font.eclass.
	font_src_install

	mkdir -p "${D}/usr/share/ja-ipafonts/"
	cp "${S}/IPA_Font_License_Agreement_v1.0.txt" "${D}/usr/share/ja-ipafonts/"
	chmod 444 "${D}/usr/share/ja-ipafonts/IPA_Font_License_Agreement_v1.0.txt"
}

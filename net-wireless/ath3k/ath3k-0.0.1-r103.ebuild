# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="2"
CROS_WORKON_COMMIT="23bd0d595e89b9760c2b49bbc32d72251493d51b"

inherit cros-workon

DESCRIPTION="Atheros AR300x firmware"
HOMEPAGE="http://www.atheros.com/"
LICENSE="Atheros"

SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

RESTRICT="binchecks strip test"
CROS_WORKON_LOCALNAME="atheros"
CROS_WORKON_PROJECT="${CROS_WORKON_LOCALNAME}"
DEPEND=""
RDEPEND=""

src_install() {
    src_dir="${S}"/ath3k/files/firmware
    dodir /lib/firmware || die
    insinto /lib/firmware
    doins -r ${src_dir}/* || die \
    	  "failed installing from ${src_dir} to ${D}/lib/firmware"
}

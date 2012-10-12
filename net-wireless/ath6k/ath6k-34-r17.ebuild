# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT=97aecef022a031b779926ef7c18067df7f1161cc
CROS_WORKON_TREE="a36293541c1ec3915933a80d5428f8a652793dbd"

EAPI="2"
CROS_WORKON_PROJECT="chromiumos/third_party/atheros"

inherit cros-workon

DESCRIPTION="Atheros AR600x firmware"
HOMEPAGE="http://www.atheros.com/"
LICENSE="Atheros"

SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

RESTRICT="binchecks strip test"
CROS_WORKON_LOCALNAME="atheros"
DEPEND=""
RDEPEND=""

src_install() {
    src_dir="${S}"/ath6k/files/firmware
    dodir /lib/firmware || die
    insinto /lib/firmware
    doins -r ${src_dir}/* || die \
    	  "failed installing from ${src_dir} to ${D}/lib/firmware"
}

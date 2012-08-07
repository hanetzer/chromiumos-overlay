# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT=be22516be2a455cab0a67ea4c4bd70e87673ef8d
CROS_WORKON_TREE="15432001bb53d7bfb41caecc20448cfbfd517d33"

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

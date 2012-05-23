# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="8060724d71a0e268acb2e9d1f2eb36e11c92f780"
CROS_WORKON_TREE="e96543d408d7091364fc9b675c788d93be60d081"

EAPI=2
CROS_WORKON_PROJECT="chromiumos/third_party/cbootimage"

inherit cros-workon

DESCRIPTION="Utility for signing Tegra2 boot images"
HOMEPAGE="http://git.chromium.org"
SRC_URI=""
LICENSE="GPLv2"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

RDEPEND=""
DEPEND=""

src_compile() {
	emake || die "emake failed"
}

src_install() {
	dodir /usr/bin
        exeinto /usr/bin

        doexe cbootimage
        doexe bct_dump
}

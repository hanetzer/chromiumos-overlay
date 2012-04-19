# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="de7ab55eb1e5da2580ef07ee77073bc872c383d7"
CROS_WORKON_TREE="a07d9340bf24790323f0f88fbe834b7542869a80"

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

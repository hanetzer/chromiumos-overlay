# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="6f2cbc73840678445a3986c520d81f5ea44e85f5"
CROS_WORKON_TREE="7081f7bde5a7a17dafb10dcd0c85c07479dd3bba"

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

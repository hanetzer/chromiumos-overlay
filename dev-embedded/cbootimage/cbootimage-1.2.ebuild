# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

EGIT_COMMIT="v${PV}"
SRC_URI="http://nv-tegra.nvidia.com/gitweb/?p=tools/cbootimage.git;a=snapshot;hb=${EGIT_COMMIT};sf=tgz -> ${PN}-${EGIT_COMMIT}.tar.gz"
S=${WORKDIR}/${PN}

inherit autotools

DESCRIPTION="Utility for signing Tegra2 boot images"
HOMEPAGE="http://nv-tegra.nvidia.com/gitweb/?p=tools/cbootimage.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

src_prepare() {
	eautoreconf
}

src_install() {
	dobin src/cbootimage src/bct_dump
}

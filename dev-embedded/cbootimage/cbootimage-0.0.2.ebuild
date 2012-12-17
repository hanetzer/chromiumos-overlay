# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

EGIT_REPO_URI="git://nv-tegra.nvidia.com/tools/cbootimage.git"
EGIT_COMMIT="ce21ef893f0a0b321c2e0a99ff8a1641d6c40625"
inherit git-2

DESCRIPTION="Utility for signing Tegra2 boot images"
HOMEPAGE="http://nv-tegra.nvidia.com/gitweb/?p=tools/cbootimage.git"
SRC_URI=""

LICENSE="GPLv2"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

src_install() {
	dobin cbootimage bct_dump
}

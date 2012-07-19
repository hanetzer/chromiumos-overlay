# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
# $Header:$
CROS_WORKON_COMMIT="a096351771ba0b1e6f0b3acaffa4a2828293dacb"
CROS_WORKON_TREE="9a0f2cd7a7ddfa3c5ce355849491cd8963b7be4a"
EAPI=4

CROS_WORKON_PROJECT="chromiumos/platform/bootcache"
CROS_WORKON_LOCALNAME="../platform/bootcache"
inherit toolchain-funcs cros-workon

DESCRIPTION="Utility for creating store for boot cache"
HOMEPAGE="http://git.chromium.org/gitweb/?s=bootcache"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

src_compile() {
	tc-export CC
	emake
}

src_install() {
	dosbin bootcache
}

# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
# $Header:$
CROS_WORKON_COMMIT=55826e9bb8f6d2f4da634d1051742f4c54953ab7
CROS_WORKON_TREE="54c869c3436c42f1273d3c4ad627fa255b92e9ca"
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

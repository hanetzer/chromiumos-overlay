# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="032ff613eb49ebc52209ca1d21d1a3bbca7afa00"
CROS_WORKON_TREE="d5c98459bbae06aacfe3fee92b8e15f0bc9db69a"
CROS_WORKON_PROJECT="chromiumos/platform/bootcache"
CROS_WORKON_LOCALNAME="../platform/bootcache"
CROS_WORKON_OUTOFTREE_BUILD=1
inherit cros-workon

DESCRIPTION="Utility for creating store for boot cache"
HOMEPAGE="http://git.chromium.org/gitweb/?s=bootcache"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

src_prepare() {
	cros-workon_src_prepare
}

src_configure() {
	cros-workon_src_configure
}

src_compile() {
	cros-workon_src_compile
}

src_install() {
	cros-workon_src_install
	dosbin "${OUT}"/bootcache

	insinto /etc/init
	doins bootcache.conf
}

# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_PROJECT="chromiumos/platform/bootcache"
CROS_WORKON_LOCALNAME="../platform/bootcache"
CROS_WORKON_OUTOFTREE_BUILD=1
inherit cros-constants cros-workon

DESCRIPTION="Utility for creating store for boot cache"
HOMEPAGE="${CROS_GIT_HOST_URL}/${CROS_WORKON_PROJECT}"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="-asan -clang"
REQUIRED_USE="asan? ( clang )"

src_prepare() {
	cros-workon_src_prepare
}

src_configure() {
	clang-setup-env
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

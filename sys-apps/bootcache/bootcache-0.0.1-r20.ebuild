# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="76687ce2cef2926746b680a813b1d4e6f150b516"
CROS_WORKON_TREE="77764e8bf9a8164739ad9464825cee09bd49845a"
CROS_WORKON_PROJECT="chromiumos/platform/bootcache"
CROS_WORKON_LOCALNAME="../platform/bootcache"
CROS_WORKON_OUTOFTREE_BUILD=1
inherit cros-constants cros-workon

DESCRIPTION="Utility for creating store for boot cache"
HOMEPAGE="${CROS_GIT_HOST_URL}/${CROS_WORKON_PROJECT}"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
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

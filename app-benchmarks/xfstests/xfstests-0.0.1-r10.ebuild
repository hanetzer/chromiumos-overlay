# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="f3a5cbbb34b717f6dbfc83d9a51435899871a939"
CROS_WORKON_TREE="8b18386ecae31e8918535b88fd1416140cd24da5"
CROS_WORKON_PROJECT="external/git.kernel.org/fs/xfs/xfstests-dev"

inherit autotools cros-workon

DESCRIPTION="Filesystem tests suite"
HOMEPAGE="https://git.kernel.org/cgit/fs/xfs/xfstests-dev.git/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

RDEPEND="sys-fs/e2fsprogs
	dev-lang/perl
	sys-apps/attr
	sys-apps/util-linux
	sys-devel/bc
	sys-fs/xfsprogs
"

DEPEND="sys-apps/acl
	dev-libs/libaio
"

src_prepare() {
	cros-workon_src_prepare
	eautoreconf
}

src_configure() {
	cros-workon_src_configure
}

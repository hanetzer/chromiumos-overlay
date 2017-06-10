# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="034744b823858c611607d0328aee4d5f01b59cec"
CROS_WORKON_TREE="12c12df855fcd2668b9bbb08cf66760037558b56"
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

# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="ecc7b5c0bafa3403c7f9a5df16d5a94226d9eed0"
CROS_WORKON_TREE="6e40016c62ab653ae23ca07faac40c6dc8cd46e6"
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

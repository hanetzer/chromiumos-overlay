# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit flag-o-matic

DESCRIPTION="Utilies for generating, examining AFDO profiles"
HOMEPAGE="http://gcc.gnu.org/wiki/AutoFDO"
SRC_URI="https://github.com/google/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="dev-libs/openssl
	dev-libs/libffi
	sys-devel/llvm
	sys-libs/zlib"
RDEPEND="${DEPEND}"

src_configure() {
	append-ldflags $(no-as-needed)
	econf
}

src_install() {
	dobin create_gcov create_llvm_prof dump_gcov profile_diff \
		profile_merger profile_update sample_merger
}

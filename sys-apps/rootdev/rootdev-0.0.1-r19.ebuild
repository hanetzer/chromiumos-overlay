# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="515197db4f204bf942b4d4f57bd994cc2e7e9c0c"
CROS_WORKON_TREE="fb4c6d4af205006a2b4b7ce0ab3e923eca534b25"
CROS_WORKON_PROJECT="chromiumos/third_party/rootdev"
CROS_WORKON_OUTOFTREE_BUILD="1"

inherit toolchain-funcs cros-workon

DESCRIPTION="Chrome OS root block device tool/library"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"
IUSE=""

src_configure() {
	cros-workon_src_configure
	tc-export CC
}

src_compile() {
	emake OUT="${WORKDIR}"
}

src_install() {
	cd "${WORKDIR}"
	dobin rootdev
	dolib.so librootdev.so*
	insinto /usr/include/rootdev
	doins "${S}"/rootdev.h
}

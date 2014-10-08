# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="aa95de66392831db1e8b56769c57be33ddd8a11a"
CROS_WORKON_TREE="4264df44fb0272e093944cc2ad3e4ec882dc099f"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_DESTDIR="${S}"

inherit toolchain-funcs cros-debug cros-workon

DESCRIPTION="TPM SmogCheck library"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
IUSE="-asan -clang"
REQUIRED_USE="asan? ( clang )"
KEYWORDS="*"

RDEPEND=""
DEPEND="${RDEPEND}
	sys-kernel/linux-headers"

src_unpack() {
	cros-workon_src_unpack
	S+="/smogcheck"
}

src_configure() {
	clang-setup-env
	cros-workon_src_configure
}

src_compile() {
	tc-export CC
	cros-debug-add-NDEBUG

	emake clean
	emake
}

src_install() {
	emake DESTDIR="${D}" install
}

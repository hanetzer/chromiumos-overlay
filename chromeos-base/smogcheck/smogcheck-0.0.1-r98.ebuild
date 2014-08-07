# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="a7dfe816f7ef68fe476f0cf1cbc7c02d88a1d8d2"
CROS_WORKON_TREE="b266df650ebf689b4809fb0cf5f2f8d5d30e7d61"
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

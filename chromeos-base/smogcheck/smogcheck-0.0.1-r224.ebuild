# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="9350136bde0e75f5a477847531a4bafe88611114"
CROS_WORKON_TREE="60711f4c7c0c6e3a5bf3e19c21e5c434153af4dd"
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

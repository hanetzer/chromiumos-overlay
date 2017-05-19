# Copyright (c) 2010 The Chromium OS Authors.  All rights reserved.
# Distributed under the terms of the GNU General Public License v2
# $Header$

EAPI="4"
CROS_WORKON_COMMIT="0cba6cadd1bea1ce3717779201d594c4c9131dc2"
CROS_WORKON_TREE="382486e1982b832b1ed427ceb5dd679bf0eb1d56"
CROS_WORKON_PROJECT="chromiumos/platform/tpm"
CROS_WORKON_LOCALNAME="../third_party/tpm"

inherit cros-workon toolchain-funcs

DESCRIPTION="Various TPM tools"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="-asan"

RDEPEND="app-crypt/trousers"
DEPEND="${RDEPEND}"

src_configure() {
	asan-setup-env
	cros-workon_src_configure
}

src_compile() {
	emake -C nvtool CC="$(tc-getCC)"
}

src_install() {
	dobin nvtool/tpm-nvtool
}

# Copyright (c) 2010 The Chromium OS Authors.  All rights reserved.
# Distributed under the terms of the GNU General Public License v2
# $Header$

EAPI="4"
CROS_WORKON_PROJECT="chromiumos/platform/tpm_lite"
CROS_WORKON_LOCALNAME="tpm_lite"

inherit cros-workon autotools
inherit cros-workon base
inherit cros-workon eutils

DESCRIPTION="TPM Light Command Library testsuite"
LICENSE="GPL-2"
HOMEPAGE="http://www.chromium.org/"
SLOT="0"
KEYWORDS="~*"

DEPEND="app-crypt/trousers"

src_configure() {
	cros-workon_src_configure
}

src_compile() {
	pushd src
	tc-export CC CXX LD AR RANLIB NM
	emake cross USE_TPM_EMULATOR=0
	popd
}

src_install() {
	pushd src
	dobin testsuite/tpmtest_*
	dolib tlcl/libtlcl.a
	popd
}

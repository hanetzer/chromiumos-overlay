# Copyright (c) 2010 The Chromium OS Authors.  All rights reserved.
# Distributed under the terms of the GNU General Public License v2
# $Header$

EAPI="4"
CROS_WORKON_COMMIT="066c7f963b3ef733716251b666e0af0afd03b4fe"
CROS_WORKON_TREE="e1d7a6d5d9b3eb03d183c7ec73a33c77c53edd2b"
CROS_WORKON_PROJECT="chromiumos/platform/tpm_lite"
CROS_WORKON_LOCALNAME="tpm_lite"

inherit cros-workon autotools
inherit cros-workon base
inherit cros-workon eutils

DESCRIPTION="TPM Light Command Library testsuite"
LICENSE="GPL-2"
HOMEPAGE="http://www.chromium.org/"
SLOT="0"
KEYWORDS="*"

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

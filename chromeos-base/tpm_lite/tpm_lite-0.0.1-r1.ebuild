# Copyright (c) 2010 The Chromium OS Authors.  All rights reserved.
# Distributed under the terms of the GNU General Public License v2
# $Header$

EAPI="2"
CROS_WORKON_COMMIT="7149ddb77c449784007ec5dd91b1ae629650657b"
inherit cros-workon autotools
inherit cros-workon base
inherit cros-workon eutils
inherit cros-workon linux-info

DESCRIPTION="TPM Light Command Library testsuite"
LICENSE="GPL-2"
HOMEPAGE="http://src.chromium.org"
SLOT="0"
KEYWORDS="amd64 arm x86"

DEPEND="app-crypt/trousers"

CROS_WORKON_LOCALNAME="tpm_lite/src"

src_compile() {
  pushd src
  tc-export CC CXX LD AR RANLIB NM
  emake cross USE_TPM_EMULATOR=0 || die emake failed
  popd
}

src_install() {
  pushd src
  dobin testsuite/tpmtest_*
  popd
}

# Copyright (c) 2010 The Chromium OS Authors.  All rights reserved.
# Distributed under the terms of the GNU General Public License v2
# $Header$

EAPI="2"

inherit autotools base eutils linux-info

DESCRIPTION="TPM Light Command Library testsuite"
LICENSE="GPL-2"
HOMEPAGE="http://src.chromium.org"
SLOT="0"
KEYWORDS="x86 amd64 arm"

DEPEND="app-crypt/trousers"

src_unpack() {
  if [ -n "$CHROMEOS_ROOT" ] ; then
    local src="${CHROMEOS_ROOT}/src/platform/tpm_lite/src"
    elog "Using src dir: $src"
    mkdir -p "${S}"
    cp -a "${src}"/* "${S}" || die
    # removes possible garbage
    (cd "${S}"; make clean)
  else
    die CHROMEOS_ROOT is not set
  fi
}

src_compile() {
  tc-export CC CXX LD AR RANLIB NM
  emake cross USE_TPM_EMULATOR=0 || die emake failed
}

src_install() {
  dobin testsuite/tpmtest_*
}

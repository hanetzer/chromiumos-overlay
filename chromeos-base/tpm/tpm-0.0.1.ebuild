# Copyright (c) 2010 The Chromium OS Authors.  All rights reserved.
# Distributed under the terms of the GNU General Public License v2
# $Header$

EAPI="2"

inherit autotools base eutils linux-info

DESCRIPTION="Various TPM tools"
LICENSE="BSD"
HOMEPAGE="http://src.chromium.org"
SLOT="0"
KEYWORDS="x86 amd64 arm"

DEPEND="app-crypt/trousers"

src_unpack() {
  if [ -n "$CHROMEOS_ROOT" ] ; then
    local tpm="${CHROMEOS_ROOT}/src/third_party/tpm"
    elog "Using tpm dir: $tpm"
    mkdir -p "${S}"
    cp -a "${tpm}"/* "${S}" || die
    # removes possible garbage
    (cd "${S}/nvtool"; make clean)
  else
    die CHROMEOS_ROOT is not set
  fi
}

src_compile() {
  if tc-is-cross-compiler ; then
    tc-getCC
    tc-getCXX
    tc-getAR
    tc-getRANLIB
    tc-getLD
    tc-getNM
    export PKG_CONFIG_PATH="${ROOT}/usr/lib/pkgconfig/"
    export CCFLAGS="$CFLAGS"
  fi
  (cd nvtool; emake) || die emake failed
}

src_install() {
  exeinto /usr/bin
  doexe nvtool/tpm-nvtool
}

# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit toolchain-funcs

DESCRIPTION="Chrome OS Metrics Collection Library."
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE=""

RDEPEND=""

DEPEND="${RDEPEND}"

src_unpack() {
  local metrics_collection="${CHROMEOS_ROOT}/src/platform/metrics_collection"
  elog "Using metrics_collection: $metrics_collection"
  mkdir -p ${S}/platform
  cp -ar "${metrics_collection}" "${S}/platform" || die
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
  pushd platform/metrics_collection
  emake || die "metrics_collection compile failed."
  popd
}

src_install() {
  pushd platform/metrics_collection
  dodir /usr/bin
  dodir /usr/sbin
  emake DESTDIR="${D}" install || die "metrics_collection install failed."
  chmod 0555 "${D}/usr/sbin/omaha_tracker.sh"
  popd
}

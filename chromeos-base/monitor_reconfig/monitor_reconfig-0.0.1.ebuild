# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit toolchain-funcs

DESCRIPTION="Chrome OS Monitor Reconfig"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE=""

DEPEND="x11-libs/libX11
        x11-libs/libXrandr"

RDEPEND="${DEPEND}
         x11-apps/xrandr"

src_unpack() {
  local monitor_reconfig="${CHROMEOS_ROOT}/src/platform/monitor_reconfig"
  elog "Using monitor_reconfig: $monitor_reconfig"
  mkdir -p "${S}"/platform
  cp -a "${monitor_reconfig}" "${S}"/platform || die
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

  pushd platform/monitor_reconfig
  emake CC="$CC" CXX="$CXX" CFLAGS="$CFLAGS" LD="$LD" || \
    die "monitor_reconfig compile failed."
  popd
}

src_install() {
  dodir /usr/sbin

  (cd "${S}"/platform/monitor_reconfig && emake DESTDIR="${D}" install) || die
}

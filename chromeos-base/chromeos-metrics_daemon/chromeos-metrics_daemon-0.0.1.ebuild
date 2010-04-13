# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit toolchain-funcs

DESCRIPTION="Chrome OS Metrics Daemon."
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE=""

RDEPEND="chromeos-base/chromeos-metrics_collection
         chromeos-base/libchrome
         >=dev-libs/glib-2.0
         dev-libs/dbus-glib
         sys-apps/dbus"

DEPEND="dev-cpp/gflags
        dev-cpp/gtest
        ${RDEPEND}"

src_unpack() {
  local metrics_daemon="${CHROMEOS_ROOT}/src/platform/metrics_daemon"
  elog "Using metrics_daemon: $metrics_daemon"
  mkdir -p "${S}"/platform
  cp -a "${metrics_daemon}" "${S}"/platform || die
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

  pushd platform/metrics_daemon
  emake CC="${CC}" CCC="${CXX}" || die "metrics_daemon compile failed."
  popd
}

src_install() {
  pushd platform/metrics_daemon
  emake DESTDIR="${D}" install || die "metrics_daemon install failed."
  popd
}

# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit toolchain-funcs

DESCRIPTION="Chrome OS Memento Updater"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE=""

DEPEND=""

RDEPEND="app-arch/gzip
         app-shells/bash
         dev-libs/openssl
         net-misc/wget
         sys-apps/coreutils
         sys-apps/util-linux"

src_unpack() {
  local updater="${CHROMEOS_ROOT}/src/platform/memento_softwareupdate"
  elog "Using updater: $updater"
  mkdir "${S}"
  cp -a "${updater}"/* "${S}" || die
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

  make || die "window_manager compile failed"
}


src_install() {
  dodir /opt/google/memento_updater

  for i in \
    memento_updater.sh \
    memento_updater_logging.sh \
    ping_omaha.sh \
    software_update.sh \
    suid_exec; do
    install -m 0755 -o root -g root "${S}"/"${i}" \
      "${D}"/opt/google/memento_updater/
  done
  
  chmod 4711 "${D}"/opt/google/memento_updater/suid_exec || die suid failed
}

# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="a827a6b568ec0ca392fe315ca1956036621c524d"

inherit cros-workon toolchain-funcs

DESCRIPTION="Chrome OS Memento Updater"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

DEPEND=""

RDEPEND="app-arch/gzip
         app-shells/bash
         dev-libs/openssl
         dev-libs/shflags
         dev-util/xxd
         net-misc/wget
         sys-apps/coreutils
         sys-apps/util-linux"

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

  make || die "memento_softwareupdate compile failed"
}

src_install() {
  exeinto /opt/google/memento_updater

  for i in \
    memento_updater.sh \
    memento_updater_logging.sh \
    ping_omaha.sh \
    software_update.sh \
    split_write; do
    doexe "${i}"
  done
}

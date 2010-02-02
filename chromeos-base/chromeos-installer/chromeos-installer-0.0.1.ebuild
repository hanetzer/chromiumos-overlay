# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit toolchain-funcs

DESCRIPTION="Chrome OS Installer"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE=""

DEPEND=""

# TODO(adlr): remove coreutils dep if we move to busybox
RDEPEND="sys-apps/coreutils
         sys-apps/util-linux
         sys-fs/e2fsprogs"

src_unpack() {
  local installer="${CHROMEOS_ROOT}/src/platform/installer"
  elog "Using installer: $installer"
  mkdir "${S}"
  cp -a "${installer}"/* "${S}" || die
}

src_install() {
  dodir /usr/sbin

  install -m 0755 -o root -g root "${S}"/chromeos-* "${D}"/usr/sbin
  ln -s usr/sbin/chromeos-postinst "${D}"/postinst
}

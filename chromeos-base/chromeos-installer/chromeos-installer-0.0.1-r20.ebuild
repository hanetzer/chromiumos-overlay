# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="a082f4ee9e1bc0b6d20bbe35b98d0e1c87e21912"
inherit cros-workon

DESCRIPTION="Chrome OS Installer"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

DEPEND=""

# TODO(adlr): remove coreutils dep if we move to busybox
RDEPEND="dev-libs/shflags
         sys-apps/coreutils
         sys-apps/util-linux
         sys-fs/e2fsprogs"

CROS_WORKON_LOCALNAME="installer"
CROS_WORKON_PROJECT="installer"

src_install() {
  dodir /usr/sbin

  install -m 0755 -o root -g root "${S}"/chromeos-* "${D}"/usr/sbin
  dosym usr/sbin/chromeos-postinst /postinst
}

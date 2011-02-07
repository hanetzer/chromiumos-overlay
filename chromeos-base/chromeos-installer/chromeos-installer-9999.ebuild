# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit cros-workon

DESCRIPTION="Chrome OS Installer"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="-minimal"

DEPEND="!!<=dev-util/crosutils-0.0.1-r1"

# TODO(adlr): remove coreutils dep if we move to busybox
# TODO(hungte): gzip is primarily for chromeos-firmware (also here for safety).
#               chromeos-installer may depend on chromeos-firmware in future.
RDEPEND="app-arch/gzip
         dev-libs/shflags
         sys-apps/coreutils
         sys-apps/util-linux
         sys-fs/dosfstools
         sys-fs/e2fsprogs"

CROS_WORKON_LOCALNAME="installer"
CROS_WORKON_PROJECT="installer"

src_install() {
	if use minimal ; then
		exeinto /usr/sbin
		dosym usr/sbin/chromeos-postinst /postinst
	else
	# Copy chromeos-* scripts to /usr/lib/installer/ on host.
		exeinto /usr/lib/installer
		dosym usr/lib/installer/chromeos-postinst /postinst
	fi

	doexe "${S}"/chromeos-*
}

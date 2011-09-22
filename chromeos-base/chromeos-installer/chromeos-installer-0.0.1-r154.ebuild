# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="39a8c79346335c3a43e23bca46a45da9d9b5b14d"
CROS_WORKON_PROJECT="chromiumos/platform/installer"

inherit cros-workon

DESCRIPTION="Chrome OS Installer"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="cros_host"

# cros-devutils <= r114 installed chromeos-setimage instead of this package.
RDEPEND="!<=chromeos-base/cros-devutils-0.0.1-r121"

# TODO(adlr): remove coreutils dep if we move to busybox
RDEPEND="$RDEPEND
	app-admin/sudo
	chromeos-base/vboot_reference
	chromeos-base/vpd
	dev-libs/shflags
	sys-apps/coreutils
	sys-apps/flashrom
	sys-apps/hdparm
	sys-apps/rootdev
	sys-apps/util-linux
	sys-apps/which
	sys-fs/dosfstools
	sys-fs/e2fsprogs"

CROS_WORKON_LOCALNAME="installer"

src_install() {
	if ! use cros_host; then
		exeinto /usr/sbin
		dosym usr/sbin/chromeos-postinst /postinst
	else
	# Copy chromeos-* scripts to /usr/lib/installer/ on host.
		exeinto /usr/lib/installer
		dosym usr/lib/installer/chromeos-postinst /postinst
	fi

	doexe "${S}"/chromeos-*
}

# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="42dbffdc4a0d4cb65695ba1fac89e309b131dfcf"
CROS_WORKON_PROJECT="chromiumos/platform/installer"

inherit cros-workon

DESCRIPTION="Chrome OS Installer"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="cros_host splitdebug"

DEPEND="
	chromeos-base/libchrome:0
	sys-libs/libbb"

# TODO(adlr): remove coreutils dep if we move to busybox
RDEPEND="
	app-admin/sudo
	chromeos-base/vboot_reference
	chromeos-base/vpd
	dev-util/shflags
	sys-apps/coreutils
	sys-apps/flashrom
	sys-apps/hdparm
	sys-apps/rootdev
	sys-apps/util-linux
	sys-apps/which
	sys-fs/dosfstools
	sys-fs/e2fsprogs"

CROS_WORKON_LOCALNAME="installer"

src_compile() {
	tc-export CXX CC OBJCOPY STRIP AR
	emake OUT=${S}/build \
		SPLITDEBUG=$(use splitdebug && echo 1) cros_installer
}

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
	dobin "${S}/build/cros_installer"
}

# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT=bac866fb55e8a93cb1f20043ca661374a8ab9c62
CROS_WORKON_TREE="0f1afa1d91ab2d861ec0ace64e047d3c517cfe7d"

EAPI="2"
CROS_WORKON_PROJECT="chromiumos/platform/userfeedback"

inherit cros-workon

DESCRIPTION="Log scripts used by userfeedback to report cros system information"
HOMEPAGE="http://www.chromium.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

RDEPEND="chromeos-base/chromeos-init
	chromeos-base/modem-utilities
	chromeos-base/vboot_reference
	media-libs/fontconfig
	sys-apps/mosys
	sys-apps/net-tools
	sys-apps/pciutils
	sys-apps/usbutils
	x11-apps/setxkbmap"

DEPEND=""

src_install() {
	exeinto /usr/share/userfeedback/scripts
	doexe scripts/* || die "Could not copy scripts"

	insinto /usr/share/userfeedback/etc
	doins etc/* || die "Could not copy etc"

        insinto /etc/init
        doins init/* || die "Could not copy init"
}

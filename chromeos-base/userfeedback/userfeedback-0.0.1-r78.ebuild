# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT=048e74af0c96b85d23ca3883565369dae3e53ccd
CROS_WORKON_TREE="1f06133a43ca385b92fb1e5c85b01465c9d3260f"

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

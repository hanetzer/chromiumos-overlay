# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT=8ac3f5981faff7f9a73b9cc93e80338b66b58bea
CROS_WORKON_TREE="3e06f71d77c414e6d69b4ad0b213bd9b6a2299a1"

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

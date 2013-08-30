# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="ed83839a56746532080e57026e2b6a9a65c1f4d1"
CROS_WORKON_TREE="a0284fdb0e2d6b369b58a67090504bfde8c564d3"
CROS_WORKON_PROJECT="chromiumos/platform/crosh"

inherit cros-workon

DESCRIPTION="Chrome OS command-line shell"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

RDEPEND="app-admin/sudo
	chromeos-base/salsa
	chromeos-base/vboot_reference
	chromeos-base/workarounds
	net-misc/iputils
	net-misc/openssh
	net-wireless/iw
	sys-apps/net-tools
"
DEPEND=""

src_install() {
	dobin crosh
	dobin crosh-dev
	dobin crosh-usb
	dobin inputrc.crosh
	dobin network_diagnostics
}

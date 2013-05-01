# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="dc9cb2eb08b69cbf689c636b5f4c2852085c67da"
CROS_WORKON_TREE="5886785af1511bef9429f1f4b358c9b4e0259478"
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
	x11-terms/rxvt-unicode
"
DEPEND=""

src_install() {
	dobin crosh
	dobin crosh-dev
	dobin crosh-usb
	dobin inputrc.crosh
	dobin network_diagnostics
}
